//
//  NotificationTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import Moya

enum NotificationTarget {
    case getAllNotification(parameters: Parameters)
    case getANotification(id: String)
    case readNotification(id: String, isRead: Bool)
    case removeNotification(id: String)
}

extension NotificationTarget: TargetType {
    
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
        case .getAllNotification:
            return "/notification"
        case .getANotification(id: let id), .readNotification(id: let id, _), .removeNotification(id: let id):
            return "/notification/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllNotification, .getANotification:
            return .get
        case .readNotification:
            return .patch
        case .removeNotification:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getAllNotification(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getANotification(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .readNotification(_, isRead: let isRead):
            return .requestParameters(parameters: ["isRead": isRead], encoding: URLEncoding.httpBody)
        case .removeNotification(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAllNotification, .getANotification, .readNotification, .removeNotification:
            return [:]
        }
    }
}
