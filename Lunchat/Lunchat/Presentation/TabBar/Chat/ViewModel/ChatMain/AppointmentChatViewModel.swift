//
//  AppointmentChatViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AppointmentChatViewModel: BaseViewModel {
    
    struct Input { }
    
    struct Output {
        let chatRooms: BehaviorSubject<[ChatRoom]>
    }
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    private let chatRooms = BehaviorSubject<[ChatRoom]>(value: [])
    private var lastMessages: [String: Message] = [:]
    
    private var useCase: ChatUseCase
    private weak var chatMainViewDelegate: ChatMainViewDelegate?
    var disposeBag = DisposeBag()
    
    init(useCase: ChatUseCase, delegate: ChatMainViewDelegate) {
        self.useCase = useCase
        self.chatMainViewDelegate = delegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(sortChatList), name: NSNotification.Name.sortChatList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChatRooms), name: NSNotification.Name.reloadChatRooms, object: nil)
    }
    
    func transform(input: Input) -> Output {
        useCase.chatRooms
            .subscribe(onNext: { [weak self] roomsData in
                guard let self = self else { return }
                
                self.total = roomsData?.meta.total ?? self.total
                self.hasNextPage = roomsData?.meta.hasNextPage ?? self.hasNextPage
                
                var updatedChatRooms: [ChatRoom] = []
                
                if let existingRooms = try? self.chatRooms.value() {
                    updatedChatRooms = self.updateChatRooms(existingRooms: existingRooms, newData: roomsData?.data ?? [])
                } else {
                    updatedChatRooms = roomsData?.data ?? []
                }
                
                updatedChatRooms.forEach { chatRoom in
                    SocketIOManager.shared.joinRoom(roomId: chatRoom.id)
                    SocketIOManager.shared.findAllMessages(roomId: chatRoom.id)
                }
                
                self.chatRooms.onNext(updatedChatRooms)
            })
            .disposed(by: disposeBag)
        
        return Output(chatRooms: chatRooms)
    }
    
    func getChatRooms() {
        useCase.getChatRooms(page: self.page, take: self.take, isPrivate: false)
    }
    
    func getMoreChatRooms() {
        guard let isLoading = try? self.isLoading.value(), !isLoading,
              let chatRooms = try? self.chatRooms.value(), chatRooms.count <= total, hasNextPage else {
            return
        }
        
        page += 1
        self.isLoading.onNext(true)
        
        useCase.getChatRooms(page: self.page, take: self.take, isPrivate: true) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func setDefaultPageOptions() {
        page = 0
        total = 0
    }
    
    func showAppointmentChatViewController(chatRoom: ChatRoom) {
        chatMainViewDelegate?.showAppointmentChatViewController(chatRoom: chatRoom)
    }
    
    @objc
    private func sortChatList(_ data: NSNotification) {
        guard let incomingMessage = data.userInfo?["message"] as? Message,
              let chatRooms = try? self.chatRooms.value()
        else { return }
        
        lastMessages[incomingMessage.roomId] = incomingMessage
        let dictionaryRoomIds = Set(lastMessages.keys)
        let chatRoomIds = Set(chatRooms.map { $0.id })
        let roomIdsToRemove = dictionaryRoomIds.subtracting(chatRoomIds)
        
        for roomIdToRemove in roomIdsToRemove {
            lastMessages.removeValue(forKey: roomIdToRemove)
        }
        
        let updatedChatRooms = updateChatRooms(existingRooms: chatRooms, newData: chatRooms)
        self.chatRooms.onNext(updatedChatRooms)
    }
    
    @objc
    private func reloadChatRooms() {
        setDefaultPageOptions()
        getChatRooms()
    }
    
    private func updateChatRooms(existingRooms: [ChatRoom], newData: [ChatRoom]) -> [ChatRoom] {
        let existingRoomIds = Set(existingRooms.map { $0.id })
        let newDataRoomIds = Set(newData.map { $0.id })
        let commonRoomIds = existingRoomIds.intersection(newDataRoomIds)
        let updatedExistingRooms = existingRooms.filter { commonRoomIds.contains($0.id) }
        
        var updatedChatRooms = updatedExistingRooms.map { room in
            var updatedRoom = room
            if let lastMessage = self.lastMessages[room.id] {
                updatedRoom.lastMessage = lastMessage
            }
            return updatedRoom
        } + newData.filter { !commonRoomIds.contains($0.id) }.map { room in
            var updatedRoom = room
            if let lastMessage = self.lastMessages[room.id] {
                updatedRoom.lastMessage = lastMessage
            }
            return updatedRoom
        }
        
        let roomIdsToRemove = existingRoomIds.symmetricDifference(newDataRoomIds)
        
        for roomIdToRemove in roomIdsToRemove {
            self.lastMessages.removeValue(forKey: roomIdToRemove)
        }
        
        updatedChatRooms.sort { room1, room2 in
            guard let timestamp1 = room1.lastMessage?.sentDate, let timestamp2 = room2.lastMessage?.sentDate else {
                return false
            }
            return timestamp1 > timestamp2
        }
        
        return updatedChatRooms
    }
}
