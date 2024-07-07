//
//  TicketRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

protocol TicketRepositoryType: AnyObject {
    func createTicket(ticket: Ticket, completion: @escaping (APIError?) -> Void)
    func getPurchaseHistory(page: Int, take: Int, completion: @escaping (Result<PurchaseHistories?,APIError>) -> Void)
    func getUseHistory(page: Int, take: Int, completion: @escaping (Result<UseHistories?,APIError>) -> Void)
    func getUnUsedTicketCount(completion: @escaping (Result<CountUnUsed?, APIError>) -> Void)
    func useTicket(toNickname: String, completion: @escaping (Result<String?, APIError>) -> Void)
}
