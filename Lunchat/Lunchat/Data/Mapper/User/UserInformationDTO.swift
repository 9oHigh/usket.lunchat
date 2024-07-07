//
//  CurrentUserDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/18.
//

import Foundation

struct UserInformationDTO: Decodable {
    let nickname: String
    let profilePicture: String?
    let gender: Bool
    let allowPushNotification: Bool
    let hasUnreadNotification: Bool
    let area: String
}

extension UserInformationDTO {
    func toObject() -> UserInformation {
        return .init(profilePicture: profilePicture, nickname: nickname, gender: gender, allowPushNotification: allowPushNotification, hasUnreadNotification: hasUnreadNotification, area: area)
    }
}
