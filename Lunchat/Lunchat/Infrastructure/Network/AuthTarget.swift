//
//  AuthTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation
import Moya

enum AuthTarget {
    case loginSocial(parameters: Parameters)
    case signupSocial(parameters: Parameters)
    case logout
    case refresh(Parameters: Parameters)
}

extension AuthTarget: TargetType {
    
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
        case .loginSocial:
            return "/auth/login/social"
        case .signupSocial:
            return "/auth/signup/social"
        case .logout:
            return "/auth/logout"
        case .refresh:
            return "/auth/refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loginSocial, .signupSocial, .refresh:
            return .post
        case .logout:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .loginSocial(let parameters), .refresh(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .signupSocial(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .logout:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .loginSocial, .signupSocial, .logout, .refresh:
            return [:]
        }
    }
}
