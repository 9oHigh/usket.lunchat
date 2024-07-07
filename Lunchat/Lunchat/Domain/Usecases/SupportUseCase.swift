//
//  SupportUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import RxSwift

final class SupportUseCase {
    
    private let supportRepository: SupportRepositoryType
    let successFeedback = PublishSubject<Bool>()
    
    init(supportRepository: SupportRepositoryType) {
        self.supportRepository = supportRepository
    }
    
    func sendFeedback(feedback: Feedback) {
        
        supportRepository.sendFeedback(feedback: feedback) { [weak self] error in
            if error != nil {
                self?.successFeedback.onNext(false)
            } else {
                self?.successFeedback.onNext(true)
            }
        }
    }
}
