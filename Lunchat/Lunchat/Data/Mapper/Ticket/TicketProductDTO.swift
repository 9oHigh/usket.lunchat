//
//  NoteProduct.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct TicketProductDTO: Decodable {
    let id: String
    let productId: String
}

extension TicketProductDTO {
    func toTicket() -> Ticket {
        return .init(paymentId: id)
    }
}
