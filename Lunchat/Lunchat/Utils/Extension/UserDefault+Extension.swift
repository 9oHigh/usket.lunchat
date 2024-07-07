//
//  UserDefault+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

enum UserInfo: String {
    case nickname
    case gender
    case profilePicture
    case bio
    case marketingInformationConsent
    
    case accessToken
    case refreshToken
    
    case kakaoAccessToken
    case kakaoRefreshToken
    
    case appleAccessToken
    
    case isFirstAuthorizationPopup
}

enum LoginStatus: String {
    case login
    case logout
}

extension UserDefaults {
    
    func setUserInfo(_ type: UserInfo, data: String) {
        UserDefaults.standard.set(data, forKey: type.rawValue)
    }
    
    func getUserInfo(_ type: UserInfo) -> String? {
        return UserDefaults.standard.string(forKey: type.rawValue)
    }
    
    func getUserGender() -> Bool {
        if let defaultGender = UserDefaults.standard.getUserInfo(.gender),
           let gender = defaultGender == "true" ? true : false {
            return gender
        } else {
            return false
        }
    }
    
    func isFirstAuthorizationPopup() -> Bool {
        if let status = UserDefaults.standard.getUserInfo(.isFirstAuthorizationPopup),
           let isFirst = status == "false" ? false : true {
            return isFirst
        }
        return true
    }

    func getLoginStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: "LoginStatus")
    }
    
    func setLoginStatus(_ loginStatus: LoginStatus) {
        UserDefaults.standard.set(loginStatus == .login ? true : false, forKey: "LoginStatus")
    }
}

extension UserDefaults {
    
    func setSafeAreaInset(_ inset: CGFloat) {
        UserDefaults.standard.set(inset, forKey: "safeAreaInset")
    }
    
    func getSafeAreaInset() -> Int {
        let inset = UserDefaults.standard.integer(forKey: "safeAreaInset")
        return inset
    }
}
