//
//  UserTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation
import Moya

typealias Parameters = [String: Any]

enum UserTarget {
    case checkUserNickname(parameters: Parameters)
    case getUserInfo
    case getUserProfile(parameters: Parameters)
    case updateUserInfo(parameters: Parameters)
    case setUserCoords(parameter: Coordinate)
    case reportUser(parameters: Parameters)
    case setUserNotification(parameters: Parameters)
    case deleteUser(parameters: Parameters)
    case setDeviceToken(parameters: Parameters)
}

extension UserTarget: TargetType {
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        guard let lunchatURL = Bundle.main.infoDictionary?["LUNCHAT_URL"] as? String,
              let url = URL(string: "https://" + lunchatURL)
        else {
            fatalError("fatal error - invalid api url")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getUserInfo:
            return "/user"
        case .getUserProfile:
            return "/user/profile"
        case .updateUserInfo:
            return "/user"
        case .checkUserNickname:
            return "/user/field-exist"
        case .setUserCoords:
            return "/user/coords"
        case .reportUser:
            return "/user/report"
        case .setUserNotification:
            return "/user/push-set"
        case .deleteUser:
            return "/user"
        case .setDeviceToken:
            return "/user/device-token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserInfo, .checkUserNickname, .getUserProfile:
            return .get
        case .updateUserInfo:
            return .patch
        case .setUserCoords, .reportUser, .setUserNotification, .setDeviceToken:
            return .post
        case .deleteUser:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUserInfo:
            return .requestPlain
        case .getUserProfile(parameters: let parameters), .checkUserNickname(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .updateUserInfo(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .setUserCoords(parameter: let parameter):
            return .requestParameters(parameters: ["latitude" : parameter.latitude, "longitude" : parameter.longitude], encoding: URLEncoding.httpBody)
        case .reportUser(parameters: let parameters), .deleteUser(parameters: let parameters), .setDeviceToken(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .setUserNotification(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .checkUserNickname, .getUserInfo, .getUserProfile, .updateUserInfo, .setUserCoords, .reportUser, .setUserNotification, .deleteUser, .setDeviceToken:
            return [:]
        }
    }
}
