//
//  PaymentRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import Moya

final class PaymentRepository: PaymentRepositoryType {
    
    private let provider: MoyaProvider<PaymentTarget> = MoyaProvider<PaymentTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func verifyApple(paymentVerifyApple: PaymentVerifyApple, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.verify(parameters: ["applePayment": ["transactionReceipt": paymentVerifyApple.transactionReceipt, "productId": paymentVerifyApple.productId]])) { [weak self] result in
            
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
                }
            }
        }
    }
}
