//
//  NoMessageType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation

enum NoChatRoomType {
    case message
    case appointment
    
    var imageName: String {
        switch self {
        case .message:
            return "emptyMessage"
        case .appointment:
            return "emptyRoom"
        }
    }
    
    var title: String {
        switch self {
        case .message:
            return "메세지가 없어요"
        case .appointment:
            return "밥약에 참여해보세요"
        }
    }
    
    var subTitle: String {
        switch self {
        case .message:
            return "쪽지를 통해\n다양한 사람들과 소통해 보세요"
        case .appointment:
            return "밥약 참여를 통해\n다양한 사람들과 소통해 보세요"
        }
    }
}
