//
//  SupportRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import Moya

final class SupportRepository: SupportRepositoryType {
    
    private let provider = MoyaProvider<SupportTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func sendFeedback(feedback: Feedback, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.feedback(parameters: ["content": feedback.content])) { result in
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
