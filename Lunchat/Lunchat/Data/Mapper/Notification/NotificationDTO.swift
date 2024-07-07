//
//  NotificationDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation

struct NotificationsDTO: Decodable {
    let meta: MetaDTO
    let data: [NotificationDTO]
}

struct NotificationDTO: Decodable {
    let id, title, content: String
    let isRead: Bool
    let createdAt: String
    let recipient: RecipientDTO
}

struct RecipientDTO: Decodable {
    let nickname: String
    let profilePicture: String
}

extension NotificationsDTO {
    func toNotifications() -> Notifications {
        return .init(meta: meta.toMeta(), data: data.compactMap { $0.toNotification() })
    }
}

extension NotificationDTO {
    func toNotification() -> Notification {
        return .init(id: id, title: title, content: content, isRead: isRead, createdAt: createdAt, recipient: recipient.toRecipient())
    }
}

extension RecipientDTO {
    func toRecipient() -> Recipient {
        return .init(nickname: nickname, profilePicture: profilePicture)
    }
}
