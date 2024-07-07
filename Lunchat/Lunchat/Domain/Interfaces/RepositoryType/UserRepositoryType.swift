//
//  UserRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

protocol UserRepositoryType: AnyObject {
    func checkUserNickname(nickname: String, completion: @escaping (Result<NicknameAvailable, APIError>) -> Void)
    func getUserInfo(completion: @escaping (Result<UserInformation?, APIError>) -> Void)
    func getUserProfile(nickname: String, completion: @escaping (Result<Profile?, APIError>) -> Void)
    func updateUserInfo(updateUserInformation: [String: Any], completion: @escaping (APIError?) -> Void )
    func setUserCoords(coords: Coordinate, completion: @escaping (APIError?) -> Void)
    func reportUser(reportUser: ReportUser, completion: @escaping (APIError?) -> Void)
    func setUserNotification(allowPushNotification: Bool, completion: @escaping (APIError?) -> Void)
    func deleteUser(deleteUser: DeleteUser, completion: @escaping (APIError?) -> Void)
}
