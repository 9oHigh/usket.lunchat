//
//  ThreadRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import Foundation
import Moya

final class ThreadRepository: ThreadRepositoryType {
    
    private let provider: MoyaProvider<ThreadTarget> = MoyaProvider<ThreadTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func getUserInfo(completion: @escaping (Result<UserInformation?, APIError>) -> Void) {
        
        provider.request(.getUserInfo) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let userInfo = try? JSONDecoder().decode(UserInformationDTO.self, from: response.data)
                    completion(.success(userInfo?.toObject()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func getPosts(page: Int, take: Int, mine: Bool, liked: Bool, completion: @escaping (Result<Posts?, APIError>) -> Void) {
        
        let parameters: [String: Any] = ["page": page, "take": take, "mine": mine ? "true" : "false", "liked": liked ? "true" : "false"]
       
        provider.request(.getPosts(parameters: parameters)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let posts = try? JSONDecoder().decode(PostsDTO.self, from: response.data)
                    completion(.success(posts?.toPosts()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func getAPost(id: String, completion: @escaping (Result<Post?, APIError>) -> Void) {
        
        provider.request(.getAPost(id: id)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let post = try? JSONDecoder().decode(PostDTO.self, from: response.data)
                    completion(.success(post?.toPost()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func createPost(fileUrl: String, title: String, content: String, placeTitle: String, placeAddress: String, placeRoadAddress: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.createPost(parameters: ["fileUrl": fileUrl, "title": title, "content": content, "placeTitle": placeTitle, "placeAddress": placeAddress, "placeRoadAddress": placeRoadAddress])) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func setLike(id: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.setLikePost(id: id)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func setDisLike(id: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.setDisLike(id: id)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func deletePost(id: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.deletePost(id: id)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
}
