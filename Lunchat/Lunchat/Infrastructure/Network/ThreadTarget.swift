//
//  ThreadTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import Foundation
import Moya

enum ThreadTarget {
    case getUserInfo
    case createPost(parameters: Parameters)
    case getPosts(parameters: Parameters)
    case getAPost(id: String)
    case setLikePost(id: String)
    case setDisLike(id: String)
    case deletePost(id: String)
}

extension ThreadTarget: TargetType {
    
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
        case .createPost:
            return "/post"
        case .getPosts:
            return "/post"
        case .getAPost(id: let id):
            return "/post/\(id)"
        case .setLikePost(id: let id):
            return "/post/\(id)/like"
        case .setDisLike(id: let id):
            return "/post/\(id)/dislike"
        case .deletePost(id: let id):
            return "/post/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserInfo, .getPosts, .getAPost:
            return .get
        case .createPost, .setLikePost, .setDisLike:
            return .post
        case .deletePost:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUserInfo:
            return .requestPlain
        case .createPost(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .getPosts(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .setLikePost(id: let id), .setDisLike(id: let id), .deletePost(id: let id), .getAPost(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUserInfo, .createPost, .getPosts, .setLikePost, .setDisLike, .deletePost, .getAPost:
            return [:]
        }
    }
}
