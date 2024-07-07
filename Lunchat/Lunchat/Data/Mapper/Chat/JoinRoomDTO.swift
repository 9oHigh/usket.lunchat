//
//  JoinRoomDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/04.
//

import Foundation

struct JoinRoomDTO: Decodable {
    let roomId: String
    let userNickname: String?
}

extension JoinRoomDTO {
    func toJoinRoom() -> JoinRoom {
        if let userNickname = self.userNickname {
            return JoinRoom(roomId: roomId, userNickname: userNickname)
        } else {
            return JoinRoom(roomId: roomId, userNickname: nil)
        }
    }
}
