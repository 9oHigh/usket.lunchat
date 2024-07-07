//
//  TicketUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import RxSwift

final class TicketUseCase {
    
    private let ticketRepository: TicketRepositoryType
    let isCreatedTicket = PublishSubject<Bool>()
    let purchaseHistories = PublishSubject<PurchaseHistories?>()
    let useHistories = PublishSubject<UseHistories?>()
    let unUsedCount = PublishSubject<CountUnUsed?>()
    let roomId = PublishSubject<String?>()
    
    init(ticketRepository: TicketRepositoryType) {
        self.ticketRepository = ticketRepository
    }
    
    func createTicket(ticket: Ticket) {
        
        ticketRepository.createTicket(ticket: ticket) { [weak self] error in
            if error != nil {
                self?.isCreatedTicket.onNext(false)
            } else {
                self?.isCreatedTicket.onNext(true)
            }
        }
    }
    
    func getPurchaseHistories(page: Int, take: Int, completion: @escaping () -> Void = { }) {
        
        ticketRepository.getPurchaseHistory(page: page, take: take) { [weak self] result in
            switch result {
            case .success(let purchaseHistroies):
                if let purchaseHistroies = purchaseHistroies {
                    self?.purchaseHistories.onNext(purchaseHistroies)
                } else {
                    self?.purchaseHistories.onNext(nil)
                }
            case .failure(_):
                self?.purchaseHistories.onNext(nil)
            }
            completion()
        }
    }
    
    func getUseHistories(page: Int, take: Int, completion: @escaping () -> Void = { }) {
        
        ticketRepository.getUseHistory(page: page, take: take) { [weak self] result in
            switch result {
            case .success(let useHistroies):
                if let useHistroies = useHistroies {
                    self?.useHistories.onNext(useHistroies)
                } else {
                    self?.useHistories.onNext(nil)
                }
            case .failure(_):
                self?.useHistories.onNext(nil)
            }
            completion()
        }
    }
    
    func getCountUnUsed() {
        
        ticketRepository.getUnUsedTicketCount { [weak self] result in
            switch result {
            case .success(let unUsedCount):
                if let unUsedCount = unUsedCount {
                    self?.unUsedCount.onNext(unUsedCount)
                } else {
                    self?.unUsedCount.onNext(nil)
                }
            case .failure(_):
                self?.unUsedCount.onNext(nil)
            }
        }
    }
    
    func useTicket(toNickname: String) {
        
        ticketRepository.useTicket(toNickname: toNickname) { [weak self] result in
            switch result {
            case .success(let roomId):
                if let roomId = roomId {
                    self?.roomId.onNext(roomId)
                } else {
                    self?.roomId.onNext(nil)
                }
            case .failure(_):
                self?.roomId.onNext(nil)
            }
        }
    }
}
