//
//  CreateMessage.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct CreateMessage: Equatable {
    let fileUrl: String?
    let sender: Sender
    let isSender: Bool
    let roomId: String
    let content: String
    let createAt: String
}

extension CreateMessage {
    func toMessage() -> Message {
        if let fileUrl = fileUrl {
            return .init(fileUrl: fileUrl, sender: Sender(senderId: sender.displayName, displayName: sender.displayName, profilePicture: sender.profilePicture), date: createAt, roomId: roomId)
        } else {
            return .init(content: content, sender: Sender(senderId: sender.displayName, displayName: sender.displayName, profilePicture: sender.profilePicture), date: createAt, roomId: roomId)
        }
    }
}
