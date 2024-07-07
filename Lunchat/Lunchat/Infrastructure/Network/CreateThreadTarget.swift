//
//  CreateThreadTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import Foundation
import Moya

enum CreateThreadTarget {
    case place(place: String, display: Int)
    case createPost(parameters: Parameters)
    case getLocationInfo(parameters: Parameters)
}

extension CreateThreadTarget: TargetType {
    
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
        case .createPost:
            return "/post"
        case .getLocationInfo:
            return "/map/reverse-geocode"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .place, .getLocationInfo:
            return .get
        case .createPost:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .place(let query, let display):
            return .requestParameters(parameters: ["query": query, "display": display], encoding: URLEncoding.default)
        case .getLocationInfo(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .createPost(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createPost, .getLocationInfo, .place:
            return [:]
        }
    }
}
