//
//  Notification.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation

struct Notifications: Equatable {
    let meta: Meta
    let data: [Notification]
}

struct Notification: Equatable {
    let id, title, content: String
    let isRead: Bool
    let createdAt: String
    let recipient: Recipient
}

struct Recipient: Equatable {
    let nickname: String
    let profilePicture: String
}
