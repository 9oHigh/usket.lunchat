//
//  JoinRoomParm.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/03.
//

import Foundation

protocol DefaultSocketParm {
    var roomId: String { get set }
    var content: String { get set }
}

struct JoinRoomParm: DefaultSocketParm {
    var roomId: String
    var content: String
    
    init(roomId: String, content: String) {
        self.roomId = roomId
        self.content = content
    }
}
