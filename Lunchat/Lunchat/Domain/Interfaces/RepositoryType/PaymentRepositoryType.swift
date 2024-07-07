//
//  PaymentRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

protocol PaymentRepositoryType: AnyObject {
    func verifyApple(paymentVerifyApple: PaymentVerifyApple, completion: @escaping (APIError?) -> Void)
}
