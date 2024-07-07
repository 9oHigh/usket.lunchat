//
//  UserStatus.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/26.
//

import Foundation

enum UserStatus {
    case nothing
    case participated
    case made
}

final class UserStatusTracker {
    
    static let shared = UserStatusTracker()
    private var status: UserStatus = .nothing
    
    func setUserStatus(status: UserStatus) {
        self.status = status
        // 홈에서 상태가 전환되었을 경우, 검색란에서 해당 약속이 보이지 않아야하므로 리프레시 필요
        NotificationCenter.default.post(name: NSNotification.Name.searchAppointmentRefresh, object: nil)
    }
    
    func getUserStatus() -> UserStatus {
        return self.status
    }
}
