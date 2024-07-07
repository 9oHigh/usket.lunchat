//
//  TicketTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import Moya

enum TicketTarget {
    case createTicket(parameters: Parameters)
    case getPurchaseHistory(parameters: Parameters)
    case getUseHistory(parameters: Parameters)
    case getUnUsedCount
    case useTicket(parameters: Parameters)
}

extension TicketTarget: TargetType {
    
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
        case .createTicket:
            return "/ticket"
        case .getPurchaseHistory:
            return "/ticket/purchase-history"
        case .getUseHistory:
            return "/ticket/use-history"
        case .getUnUsedCount:
            return "/ticket/unused-count"
        case .useTicket:
            return "/ticket/use"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createTicket, .useTicket:
            return .post
        case .getPurchaseHistory, .getUseHistory, .getUnUsedCount:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getPurchaseHistory(let parameters), .getUseHistory(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .createTicket(let parameters), .useTicket(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case  .getUnUsedCount:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createTicket, .getPurchaseHistory, .getUseHistory, .getUnUsedCount, .useTicket:
            return [:]
        }
    }
}
