//
//  PurchaseViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyStoreKit

enum ProductId: String, CaseIterable {
    case one = "ticket_bundle_1_230504"
    case three = "ticket_bundle_3_230504"
    case five = "ticket_bundle_5_230504"
    case ten = "ticket_bundle_10_230504"
    case twenty = "ticket_bundle_20_230504"
    case thirty = "ticket_bundle_30_230504"
}

final class PurchaseViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let ticketCount: BehaviorSubject<String>
    }
    
    private let ticketCount = BehaviorSubject<String>(value: "0")
    var currentProductId: ProductId?
    
    private weak var shopViewDelegate: ShopViewDelegate?
    private let paymentUseCase: PaymentUseCase
    private let ticketUseCase: TicketUseCase
    var disposeBag = DisposeBag()
    
    init(paymentUseCase: PaymentUseCase, ticketUseCase: TicketUseCase, delegate: ShopViewDelegate) {
        self.paymentUseCase = paymentUseCase
        self.ticketUseCase = ticketUseCase
        self.shopViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        ticketUseCase.getCountUnUsed()
        
        ticketUseCase.unUsedCount
            .subscribe({ [weak self] count in
                if let count = count.element,
                   let count = count {
                    self?.ticketCount.onNext(String(count.ticketCount))
                }
            })
            .disposed(by: disposeBag)
        
        paymentUseCase.ticket
            .subscribe({ [weak self] ticket in
                if let ticket = ticket.element, ticket != nil {
                    self?.shopViewDelegate?.showTicketCreateFailure()
                } else {
                    self?.shopViewDelegate?.showTicketCreateSuccess()
                    self?.ticketUseCase.getCountUnUsed()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name.removeLoadingView, object: nil)
            })
            .disposed(by: disposeBag)
        
        return Output(ticketCount: ticketCount)
    }
    
    func showNoteTicketCreate(ticket: TicketType) {
        self.shopViewDelegate?.showTicketCreateView(ticket: ticket, viewModel: self)
    }

    func buyProduct(productID: String) {
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { [weak self] result in
            switch result {
            case .success(let purchase):
                SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
                    switch result {
                    case .success(let receiptData):
                        let receiptString = receiptData.base64EncodedString()
                        self?.paymentUseCase.verifyApple(paymentVerifyApple: PaymentVerifyApple(transactionReceipt: receiptString, productId: purchase.productId))
                    case .error(_):
                        self?.shopViewDelegate?.showTicketCreateFailure()
                        NotificationCenter.default.post(name: NSNotification.Name.removeLoadingView, object: nil)
                    }
                }
            case .error(_), .deferred(_):
                self?.shopViewDelegate?.showTicketCreateFailure()
                NotificationCenter.default.post(name: NSNotification.Name.removeLoadingView, object: nil)
            }
        }
    }
}
