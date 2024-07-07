//
//  ChatTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation
import Moya

enum ChatTarget {
    case getChatRooms(page: Int, take: Int, isPrivate: Bool)
    case getSpecificChatRoom(id: String)
}

extension ChatTarget: TargetType {
    
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
        case .getChatRooms:
            return "/chat/room"
        case .getSpecificChatRoom(id: let id):
            return "/chat/room/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getChatRooms(page: let page, take: let take, isPrivate: let isPrivate):
            return .requestParameters(parameters: ["page": page, "take": take, "isPrivate": isPrivate ? "true" : "false"], encoding: URLEncoding.queryString)
        case .getSpecificChatRoom(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
