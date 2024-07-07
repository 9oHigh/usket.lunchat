//
//  PaymentTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import Moya

enum PaymentTarget {
    case verify(parameters: Parameters)
}

extension PaymentTarget: TargetType {
    
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
        case .verify:
            return "/ticket"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verify:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .verify(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .verify:
            return [:]
        }
    }
}
