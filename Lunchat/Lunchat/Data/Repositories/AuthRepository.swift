//
//  AuthRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation
import Moya

final class AuthRepository: AuthRepositoryType {
  
    private let provider: MoyaProvider<AuthTarget> = MoyaProvider<AuthTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func socialSignup(userInfo: SignupSocial, completion: @escaping (Result<Tokens?, APIError>) -> Void) {
        
        provider.request(.signupSocial(parameters: ["authProvider": userInfo.authProvider, "accessToken": userInfo.accessToken, "nickname": userInfo.nickname, "gender": userInfo.gender, "bio": userInfo.bio, "marketingInformationConsent": userInfo.marketingInformationConsent])) { result in
            
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    if let tokens = try? JSONDecoder().decode(TokensDTO.self, from: response.data) {
                        completion(.success(tokens.toObject()))
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

    func socialLogin(info: LoginSocial, completion: @escaping (Result<Tokens?, APIError>) -> Void) {
        
        provider.request(.loginSocial(parameters: ["accessToken": info.accessToken, "authProvider": info.authProvider])) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    if let tokens = try? JSONDecoder().decode(TokensDTO.self, from: response.data) {
                        completion(.success(tokens.toObject()))
                    }
                } else if let _ = try? response.filter(statusCode: 404) {
                    completion(.success(nil))
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
    
    func logout(completion: @escaping (APIError?) -> Void) {
        
        provider.request(.logout) { result in
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
    
    func refreshToken(refreshToken: String, completion: @escaping (Result<Tokens?, APIError>) -> Void) {
        
        provider.request(.refresh(Parameters: ["refreshToken": refreshToken])) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    if let tokens = try? JSONDecoder().decode(TokensDTO.self, from: response.data) {
                        completion(.success(tokens.toObject()))
                    }
                } else if let _ = try? response.filter(statusCode: 404) {
                    completion(.success(nil))
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
}
