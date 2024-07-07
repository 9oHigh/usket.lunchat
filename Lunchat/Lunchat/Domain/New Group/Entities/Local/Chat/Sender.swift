//
//  Sender.swift
//  Lunchat
//
//  Created by 이경후 on 4/3/24.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var profilePicture: String
}

extension Sender: Equatable {
    static func == (lhs: Sender, rhs: Sender) -> Bool {
        return lhs.displayName == rhs.displayName
    }
}
