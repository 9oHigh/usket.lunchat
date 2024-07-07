//
//  AuthUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation
import RxSwift

final class AuthUseCase {
    
    private let authRepository: AuthRepositoryType
    
    let loginSign = PublishSubject<Bool>()
    let signupSign = PublishSubject<Bool>()
    let logoutSign = PublishSubject<Bool>()
    
    init(authRepository: AuthRepositoryType) {
        self.authRepository = authRepository
    }

    func socialSignup(signupSocial: SignupSocial) {

        authRepository.socialSignup(userInfo: signupSocial) { [weak self] result in
            switch result {
            case .success(let accessToken):
                if let accessToken = accessToken {
                    UserDefaults.standard.setUserInfo(.accessToken, data: accessToken.accessToken)
                    UserDefaults.standard.setUserInfo(.refreshToken, data: accessToken.refreshToken)
                    UserDefaults.standard.setUserInfo(.nickname, data: signupSocial.nickname)
                    UserDefaults.standard.setUserInfo(.gender, data: signupSocial.gender ? "true" : "false")
                    UserDefaults.standard.setUserInfo(.bio, data: signupSocial.bio)
                    UserDefaults.standard.setUserInfo(.marketingInformationConsent, data: signupSocial.marketingInformationConsent ? "true" : "false")
                    self?.signupSign.onNext(true)
                } else {
                    self?.signupSign.onNext(false)
                }
            case .failure(_):
                self?.signupSign.onNext(false)
            }
        }
    }
    
    func socialLogin(accessToken: String, authProvider: String) {
        
        let requestInfo = LoginSocial(accessToken: accessToken, authProvider: authProvider)
        
        authRepository.socialLogin(info: requestInfo) { [weak self] result in
            switch result {
            case .success(let accessToken):
                if let accessToken = accessToken {
                    UserDefaults.standard.setUserInfo(.accessToken, data: accessToken.accessToken)
                    UserDefaults.standard.setUserInfo(.refreshToken, data: accessToken.refreshToken)
                    self?.loginSign.onNext(true)
                } else {
                    self?.loginSign.onNext(false)
                }
            case .failure(_):
                self?.loginSign.onNext(false)
            }
        }
    }
    
    func logout() {
        
        authRepository.logout { [weak self] error in
            if error == nil {
                self?.logoutSign.onNext(true)
            } else {
                self?.logoutSign.onNext(false)
            }
        }
    }
    
    func refreshToken(refreshToken: String, completion: @escaping (Result<Tokens?, APIError>) -> Void) {
        
        authRepository.refreshToken(refreshToken: refreshToken) { result in
            switch result {
            case .success(let tokens):
                if let tokens = tokens {
                    UserDefaults.standard.setUserInfo(.accessToken, data: tokens.accessToken)
                    UserDefaults.standard.setUserInfo(.refreshToken, data: tokens.refreshToken)
                    completion(.success(tokens))
                } else {
                    completion(.failure(.unknown))
                }
            case .failure(_):
                completion(.failure(.unknown))
            }
        }
    }
}
