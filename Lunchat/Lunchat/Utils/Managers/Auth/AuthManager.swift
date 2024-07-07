//
//  AuthManager.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/12.
//

import UIKit
import Moya

final class AuthManager {
    
    static let shared = AuthManager()
    // 연산 프로퍼티로 할 필요없음. 싱글턴임.
    private var refreshToken: String = UserDefaults.standard.getUserInfo(.refreshToken) ?? ""
    
    func renewToken(completion: @escaping (Result<Tokens?, APIError>) -> Void) {
        
        let authRepository = AuthRepository()
        let authUseCase = AuthUseCase(authRepository: authRepository)
        
        authUseCase.refreshToken(refreshToken: self.refreshToken) { result in
            switch result {
            case .success(let tokens):
                if let tokens = tokens {
                    AuthManager.shared.refreshToken = tokens.refreshToken
                    completion(.success(tokens))
                } else {
                    AlertManager.shared.showReLogin {
                        self.restartAuthCoordinator()
                    }
                    completion(.failure(.unknown))
                }
            case .failure(_):
                AlertManager.shared.showReLogin {
                    self.restartAuthCoordinator()
                }
            }
        }
    }
    
    private func restartAuthCoordinator() {
        UserDefaults.standard.setLoginStatus(.logout)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        sceneDelegate?.restart()
    }

    /*
     private func setKakaoRefreshToken() {
         AuthApi.shared.refreshToken { token, error in
             guard error == nil else { return }
             let refreshToken = token?.refreshToken
             let accessToken = token?.accessToken
             UserDefaults.standard.setUserInfo(.kakaoRefreshToken, data: refreshToken!)
             UserDefaults.standard.setUserInfo(.kakaoAccessToken, data: accessToken!)
         }
     }
    */
}

