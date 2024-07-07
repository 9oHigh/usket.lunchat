//
//  PaymentUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import RxSwift

final class PaymentUseCase {
    
    private let paymentRepository: PaymentRepositoryType
    let ticket = PublishSubject<Ticket?>()

    init(paymentRepository: PaymentRepositoryType) {
        self.paymentRepository = paymentRepository
    }
    
    func verifyApple(paymentVerifyApple: PaymentVerifyApple) {
        
        paymentRepository.verifyApple(paymentVerifyApple: paymentVerifyApple) { [weak self] ticket in
            
            if ticket == nil {
                self?.ticket.onNext(nil)
            } else {
                self?.ticket.onNext(Ticket(paymentId: "payment"))
            }
        }
    }
}
