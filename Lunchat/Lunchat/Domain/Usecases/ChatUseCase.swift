//
//  ChatUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation
import RxSwift

final class ChatUseCase {
    
    private var chatRepository: ChatRepositoryType
    let chatRooms = PublishSubject<ChatRooms?>()
    let chatRoom = PublishSubject<ChatRoom?>()
    
    init(chatRepository: ChatRepositoryType) {
        self.chatRepository = chatRepository
    }
    
    func getChatRooms(page: Int, take: Int, isPrivate: Bool, completion: @escaping () -> Void = { }) {
        
        chatRepository.getChatRooms(page: page, take: take, isPrivate: isPrivate) { [weak self] result in
            switch result {
            case .success(let chatRooms):
                if let chatRooms = chatRooms {
                    self?.chatRooms.onNext(chatRooms)
                } else {
                    self?.chatRooms.onNext(nil)
                }
                completion()
            case .failure(_):
                self?.chatRooms.onNext(nil)
                completion()
            }
        }
    }
    
    func getSpecificChatRoom(id: String) {
        
        chatRepository.getSpecificChatRoom(id: id) { [weak self] result in
            switch result {
            case .success(let chatRoom):
                if let chatRoom = chatRoom {
                    self?.chatRoom.onNext(chatRoom)
                } else {
                    self?.chatRoom.onNext(nil)
                }
            case .failure(_):
                self?.chatRoom.onNext(nil)
            }
        }
    }
}
