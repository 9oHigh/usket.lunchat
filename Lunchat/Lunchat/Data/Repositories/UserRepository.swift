//
//  UserRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation
import Moya

final class UserRepository: UserRepositoryType {
    
    private let provider: MoyaProvider<UserTarget> = MoyaProvider<UserTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func checkUserNickname(nickname: String, completion: @escaping (Result<NicknameAvailable, APIError>) -> Void) {
        
        provider.request(.checkUserNickname(parameters: ["nickname": nickname])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    if let userInfo = try? JSONDecoder().decode(NicknameAvailableDTO.self, from: response.data) {
                        completion(.success(userInfo.toObject()))
                    }
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
    
    func getUserInfo(completion: @escaping (Result<UserInformation?, APIError>) -> Void) {
        
        provider.request(.getUserInfo) { [weak self] result in
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
    
    func getUserProfile(nickname: String, completion: @escaping (Result<Profile?, APIError>) -> Void) {
        
        provider.request(.getUserProfile(parameters: ["nickname": nickname])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let profile = try? JSONDecoder().decode(ProfileDTO.self, from: response.data)
                    completion(.success(profile?.toProfile()))
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
    
    func updateUserInfo(updateUserInformation: [String: Any], completion: @escaping (APIError?) -> Void) {
        
        provider.request(.updateUserInfo(parameters: updateUserInformation)) { [weak self] result in
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
    
    func setUserCoords(coords: Coordinate, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.setUserCoords(parameter: coords)) { [weak self] result in
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

    func reportUser(reportUser: ReportUser, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.reportUser(parameters: ["nickname": reportUser.nickname, "reason": reportUser.reason])) { [weak self] result in
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
    
    func setUserNotification(allowPushNotification: Bool, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.setUserNotification(parameters: ["allowPushNotification": allowPushNotification])) { [weak self] result in
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
    
    func deleteUser(deleteUser: DeleteUser, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.deleteUser(parameters: ["reason": deleteUser.reason])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    UserDefaults.standard.setLoginStatus(.logout)
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
