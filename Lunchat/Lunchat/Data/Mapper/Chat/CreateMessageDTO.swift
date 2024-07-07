//
//  CreateMessageDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct CreateMessageDTO: Decodable {
    let fileUrl: String?
    let sender: ChatSenderDTO
    let isSender: Bool
    let roomId: String
    let content: String
    let createdAt: String
}

extension CreateMessageDTO {
    func toCreateMessage() -> CreateMessage {
        return .init(fileUrl: fileUrl, sender: sender.toSender(), isSender: isSender, roomId: roomId, content: content, createAt: createdAt)
    }
}
