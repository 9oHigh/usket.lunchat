//
//  SearchTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation
import Moya

enum SearchTarget {
    case place(place: String, display: Int)
    case user(page: Int, take: Int, nickname: String)
    case appointment(page: Int, take: Int, keyword: String, option: String)
}

extension SearchTarget: TargetType {
    
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
        case .place:
            return "/search/place"
        case .user:
            return "/search/user"
        case .appointment:
            return "/search/appointment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .place, .user, .appointment:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .place(let query, let display):
            return .requestParameters(parameters: ["query": query, "display": display], encoding: URLEncoding.default)
        case .user(page: let page, take: let take, nickname: let nickname):
            return .requestParameters(parameters: ["page": page, "take": take, "nickname": nickname], encoding: URLEncoding.queryString)
        case .appointment(page: let page, take: let take, keyword: let keyword, option: let option):
            return .requestParameters(parameters: ["page": page, "take": take, "keyword": keyword, "option": option], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .place, .user, .appointment:
            return [:]
        }
    }
}
