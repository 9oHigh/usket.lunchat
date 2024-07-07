//
//  ChatMessagesDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct ChatMessagesDTO: Decodable {
    let fileUrl: String?
    let sender: ChatSenderDTO
    let isSender: Bool
    let roomId: String
    let content: String
    let createdAt: String
}

extension ChatMessagesDTO {
    func toChatMessages() -> ChatMessages {
        return .init(fileUrl: fileUrl, sender: sender.toSender(), isSender: isSender, roomId: roomId, content: content, createdAt: createdAt)
    }
}
