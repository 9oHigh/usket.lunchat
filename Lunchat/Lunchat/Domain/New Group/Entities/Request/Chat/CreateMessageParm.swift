//
//  CreateMessageParm.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/03.
//

import Foundation

struct CreateMessageParm: DefaultSocketParm {
    var roomId: String
    var content: String
    var fileId: String?
    
    init(roomId: String, content: String) {
        self.roomId = roomId
        self.content = content
    }
    
    init(roomId: String, content: String, fileId: String) {
        self.roomId = roomId
        self.content = content
        self.fileId = fileId
    }
}
