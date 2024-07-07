//
//  ChatRoom.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation

struct ChatRooms: Equatable {
    let meta: Meta
    let data: [ChatRoom]
}

struct ChatRoom: Equatable {
    let id: String
    let isPrivate, isClosed: Bool
    let currParticipants, maxParticipants: Int
    let participants: [Participant]
    let files: [FileInfo]?
    var lastMessage: Message?
    
    mutating func updateLastMessage(_ message: Message) {
        self.lastMessage = message
    }
}

struct FileInfo: Equatable {
    let fileID: String
    let fileURL: String
    let fileType, createdAt: String    
}
