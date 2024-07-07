//
//  ProfileEnums.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/13.
//

import Foundation

enum SettingSectionType: String, CaseIterable {
    
    case feedback = "개선"
    case notification = "공지"
    case support = "지원 & 정보"
    case userStatus = "로그아웃 & 회원탈퇴"
    case version = "버전"
    
    var numberOfRows: Int {
        switch self {
        case .feedback:
            return 1
        case .notification:
            return 1
        case .support:
            return 4
        case .userStatus:
            return 2
        case .version:
            return 1
        }
    }
    
    var titleForHeader: String {
        return self.rawValue
    }
}

enum FeedbackType: String {
    case feedback
    
    var title: String {
        switch self {
        case .feedback:
            return "피드백 남기기"
        }
    }
}

enum NotificationType: String {
    case notification
    
    var title: String {
        switch self {
        case .notification:
            return "공지사항"
        }
    }
    
    var url: URL? {
        return URL(string: "https://home.lunchat.co/notice.html")
    }
}

enum SupprotType: String {
    case customerService
    case openSource
    case serviceTerm
    case policy
    
    var title: String {
        switch self {
        case .customerService:
            return "고객센터"
        case .openSource:
            return "오픈소스 라이선스"
        case .serviceTerm:
            return "서비스 약관"
        case .policy:
            return "개인정보처리방침"
        }
    }
    
    var url: URL? {
        switch self {
        case .customerService:
            return URL(string: "https://home.lunchat.co/faq.html")
        case .serviceTerm:
            return URL(string: "https://home.lunchat.co/terms-of-service.html")
        case .policy:
            return URL(string: "https://home.lunchat.co/privacy-policy.html")
        default:
            return nil
        }
    }
}

enum UserStatusType: String {
    case logout
    case withdrawal
    
    var title: String {
        switch self {
        case .logout:
            return "로그아웃"
        case .withdrawal:
            return "회원탈퇴"
        }
    }
}

enum VersionType: String {
    case current
    
    var title: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            switch self {
            case .current:
                return "현재버전(\(appVersion))"
            }
        } else {
            return "현재버전(1.0.0)"
        }
    }
}

enum SettingCellType {
    static var allCases: [[SettingCellType]] {
        return [[feedback(.feedback)], [notification(.notification)], [support(.customerService), support(.openSource), support(.serviceTerm), support(.policy)], [userStatus(.logout), userStatus(.withdrawal)], [version(.current)]]
    }
    case feedback(FeedbackType)
    case notification(NotificationType)
    case support(SupprotType)
    case userStatus(UserStatusType)
    case version(VersionType)
}
