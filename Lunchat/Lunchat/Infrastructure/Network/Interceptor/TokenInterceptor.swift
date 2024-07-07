//
//  TokenRefreshPlugin.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/31.
//

import Foundation
import Alamofire

final class TokenInterceptor: RequestInterceptor {
    
    static let shared = TokenInterceptor()
    private var isRefreshing = false
    private var requestsToRetry: [() -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let lunchatURL = Bundle.main.infoDictionary?["LUNCHAT_URL"] as? String,
                let accessToken = UserDefaults.standard.getUserInfo(.accessToken),
                let requestURLString = urlRequest.url?.absoluteString,
                requestURLString.contains(lunchatURL)
            else {
                completion(.success(urlRequest))
                return
            }
        
        var request = urlRequest
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401
        else {
            completion(.doNotRetry)
            return
        }
        
        if isRefreshing {
            requestsToRetry.append { completion(.retry) }
            return
        }
        
        isRefreshing = true
        
        AuthManager.shared.renewToken { [weak self] result in
            switch result {
            case .success(let tokens):
                if let tokens = tokens {
                    UserDefaults.standard.setUserInfo(.accessToken, data: tokens.accessToken)
                    UserDefaults.standard.setUserInfo(.refreshToken, data: tokens.refreshToken)
                    self?.requestsToRetry.append { completion(.retry) }
                    self?.executePendingRequests()
                }
            case .failure(_):
                break
            }
            
            self?.isRefreshing = false
        }
    }
    
    private func executePendingRequests() {
        requestsToRetry.forEach { $0() }
        requestsToRetry.removeAll()
    }
}
