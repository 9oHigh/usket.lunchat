//
//  ProfileBottomSheetTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/17.
//

import Foundation
import Moya

enum ProfileBottomSheetTarget {
    case getUserProfile(parameters: Parameters)
    case getUserTicketCount
    case useTicket(parameters: Parameters)
    case reportUser(parameters: Parameters)
    case getSpecificChatRoom(id: String)
}

extension ProfileBottomSheetTarget: TargetType {
    
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
        case .getUserProfile:
            return "/user/profile"
        case .getUserTicketCount:
            return "/ticket/unused-count"
        case .reportUser:
            return "/user/report"
        case .useTicket:
            return "/ticket/use"
        case .getSpecificChatRoom(id: let id):
            return "/chat/room/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserProfile, .getUserTicketCount, .getSpecificChatRoom:
            return .get
        case .useTicket, .reportUser:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUserProfile(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getSpecificChatRoom(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .getUserTicketCount:
            return .requestPlain
        case .reportUser(parameters: let parameters), .useTicket(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUserProfile, .reportUser, .useTicket, .getUserTicketCount, .getSpecificChatRoom:
            return [:]
        }
    }
}
