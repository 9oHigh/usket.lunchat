//
//  SocketManager.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/28.
//

import UIKit
import SocketIO

final class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    private var joinedRoom: [String] = []
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    override init() {
        super.init()
        guard let url = URL(string: (Bundle.main.infoDictionary?["CHAT_URL"] as? String)!),
              let accessToken = UserDefaults.standard.getUserInfo(.accessToken)
        else {
            fatalError("fatal error - invalid api url")
        }
        manager = SocketManager(socketURL: url, config: [
            .log(true),
            .extraHeaders(["Authorization": "Bearer \(accessToken)"])
        ])
        socket = manager.defaultSocket
        socket = manager.socket(forNamespace: "/chat")
        addEventHandlers()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    // MARK: - Notification을 사용하지 않는 방법을 알아내보자 ( 리팩토링 )
    func addEventHandlers() {
        socket.on("joinRoom") { _, _ in }
        
        socket.on("leaveRoom") { [weak self] dataArray, _ in
            
            guard let data = dataArray.first as? [String: Any],
                  let roomId = data["roomId"]
            else {
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.reloadChatRooms, object: nil, userInfo: ["roomId": roomId])
        }
        
        socket.on("createMessage") { [weak self] dataArray, _ in
            
            guard let data = dataArray.first as? [String: Any] else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                let inCommingMessage = try decoder.decode(CreateMessageDTO.self, from: jsonData).toCreateMessage().toMessage()
                
                NotificationCenter.default.post(name: NSNotification.Name.recievedMessage, object: nil, userInfo: [
                    "messages": inCommingMessage
                ])
                
                NotificationCenter.default.post(name: NSNotification.Name.sortChatList, object: nil, userInfo: [
                    "message": inCommingMessage
                ])
            } catch {
                print("Error decoding CreateMessageDTO data: \(error)")
            }
        }
    }
}

extension SocketIOManager {
    
    func joinRoom(roomId: String) {
        let data: [String: Any] = ["roomId": roomId]
        
        if self.joinedRoom.contains(roomId) {
            return
        }
        
        socket.emitWithAck("joinRoom", data).timingOut(after: 0) { [weak self] dataArray in
            guard let data = dataArray.first as? [String: Any],
                  let roomId = data["roomId"] as? String
            else {
                return
            }
            
            self?.joinedRoom.append(roomId)
        }
    }
    
    func findAllMessages(roomId: String) {
        let data: [String: Any] = ["roomId": roomId, "limit": 10000]
        
        socket.emitWithAck("findAllMessages", data).timingOut(after: 0.0) { [weak self] dataArray in
            guard let data = dataArray.first as? [[String: Any]] else {
                NotificationCenter.default.post(name: NSNotification.Name.findAllMessages, object: nil, userInfo: nil)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                let message = try decoder.decode([ChatMessagesDTO].self, from: jsonData)
                let messages = Array(message.map { $0.toChatMessages() }.compactMap { $0.toMessage() }.reversed())
                
                if let lastMessage = messages.last {
                    NotificationCenter.default.post(name: NSNotification.Name.sortChatList, object: nil, userInfo: [
                        "message": lastMessage
                    ])
                    
                    NotificationCenter.default.post(name: NSNotification.Name.findAllMessages, object: nil, userInfo: [
                        "messages": messages
                    ])
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.findAllMessages, object: nil, userInfo: nil)
                }
            } catch {
                print("Error decoding FindAllMessagesDTO data: \(error)")
            }
        }
    }
    
    func sendMessage(parm: CreateMessageParm) {
        let data: [String: Any] = ["roomId": parm.roomId, "content": parm.content]
        
        socket.emitWithAck("createMessage", data).timingOut(after: 0.0) { [weak self] dataArray in
            
            guard let data = dataArray.first as? [String: Any] else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                let inCommingMessage = try decoder.decode(CreateMessageDTO.self, from: jsonData).toCreateMessage().toMessage()
                
                NotificationCenter.default.post(name: NSNotification.Name.recievedMessage, object: nil, userInfo: [
                    "messages": inCommingMessage
                ])
            } catch {
                print("Error decoding CreateMessageDTO data: \(error)")
            }
        }
    }
    
    func sendImageMessage(parm: CreateMessageParm) {
        guard let fileId = parm.fileId, !fileId.isEmpty
        else {
            return
        }
        
        let data: [String: Any] = ["roomId": parm.roomId, "content": parm.content, "fileId": fileId]
        
        socket.emitWithAck("createMessage", data).timingOut(after: 0.0) { [weak self] dataArray in
            guard let data = dataArray.first as? [String: Any] else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                let inCommingMessage = try decoder.decode(CreateMessageDTO.self, from: jsonData).toCreateMessage().toMessage()
                
                NotificationCenter.default.post(name: NSNotification.Name.recievedMessage, object: nil, userInfo: [
                    "messages": inCommingMessage
                ])
            } catch {
                print("Error decoding CreateMessageDTO data: \(error)")
            }
        }
    }
    
    func leaveRoom(roomId: String) {
        
        let data: [String: Any] = ["roomId": roomId]
        
        socket.emitWithAck("leaveRoom", data).timingOut(after: 0.0) { [weak self] dataArray in
            guard let data = dataArray.first as? [String: Any],
                  let roomId = data["roomId"] as? String
            else {
                return
            }
            
            if let index = self?.joinedRoom.firstIndex(of: roomId) {
                self?.joinedRoom.remove(at: index)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.leaveRoomSuccess, object: nil)
        }
    }
}
