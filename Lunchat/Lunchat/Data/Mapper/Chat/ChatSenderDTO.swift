//
//  ChatSenderDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct ChatSenderDTO: Decodable {
    let nickname: String
    let profilePicture: String
}

extension ChatSenderDTO {
    func toSender() -> Sender {
        return Sender(senderId: nickname, displayName: nickname, profilePicture: profilePicture)
    }
}
