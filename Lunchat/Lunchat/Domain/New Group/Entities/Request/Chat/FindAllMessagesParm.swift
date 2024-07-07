//
//  FindAllMessagesParm.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/03.
//

import Foundation

struct FindAllMessagesParm: DefaultSocketParm {
    var roomId: String
    var content: String
    var limit: Int
    
    init(roomId: String, content: String, limit: Int) {
        self.roomId = roomId
        self.content = content
        self.limit = limit
    }
}
