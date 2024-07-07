//
//  ChatRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation

protocol ChatRepositoryType: AnyObject {
    func getChatRooms(page: Int, take: Int, isPrivate: Bool, completion: @escaping (Result<ChatRooms?, APIError>) -> Void)
    func getSpecificChatRoom(id: String, completion: @escaping (Result<ChatRoom?, APIError>) -> Void)
}
