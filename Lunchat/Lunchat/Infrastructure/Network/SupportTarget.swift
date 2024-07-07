//
//  SupportTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import Moya

enum SupportTarget {
    case feedback(parameters: Parameters)
}

extension SupportTarget: TargetType {
    
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
        case .feedback:
            return "/support/feedback"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .feedback:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .feedback(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .feedback:
            return [:]
        }
    }

}
