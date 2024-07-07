//
//  ChatMessages.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct ChatMessages: Equatable {
    let fileUrl: String?
    let sender: Sender
    let isSender: Bool
    let roomId: String
    let content: String
    let createdAt: String
}

extension ChatMessages {
    func toMessage() -> Message {
        if let fileUrl = fileUrl, !fileUrl.isEmpty {
            return .init(fileUrl: fileUrl, sender: sender, date: createdAt, roomId: roomId)
        } else {
            return .init(content: content, sender: sender, date: createdAt, roomId: roomId)
        }
    }
}
