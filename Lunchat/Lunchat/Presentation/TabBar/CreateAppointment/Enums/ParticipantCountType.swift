//
//  ParticipantCountType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/05.
//

import Foundation

enum ParticipantCountType: Int {
    case two = 2
    case three = 3
    case four = 4
    
    var title: String {
        switch self {
        case .two:
            return "2명"
        case .three:
            return "3명"
        case .four:
            return "4명"
        }
    }
}
