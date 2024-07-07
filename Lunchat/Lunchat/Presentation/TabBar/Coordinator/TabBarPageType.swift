//
//  TabBarPageType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import Foundation

enum TabBarPageType: String, CaseIterable {
    
    case thread
    case search
    case lunchat
    case chat
    case profile
    
    init?(index: Int) {
        switch index {
        case 0: self = .thread
        case 1: self = .search
        case 2: self = .lunchat
        case 3: self = .chat
        case 4: self = .profile
        default: return nil
        }
    }
    
    var pageTitle: String? {
        switch self {
        case .thread:
            return "쓰레드"
        case .search:
            return "검색"
        case .lunchat:
            return nil
        case .chat:
            return "채팅"
        case .profile:
            return "프로필"
        }
    }
    
    var pageOrderNumber: Int {
        switch self {
        case .thread: return 0
        case .search: return 1
        case .lunchat: return 2
        case .chat: return 3
        case .profile: return 4
        }
    }
    
    var iconName: String {
        return self.rawValue
    }
}
