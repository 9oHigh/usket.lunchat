//
//  PurchaseHistoryDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct PurchaseHistoriesDTO: Decodable {
    let meta: MetaDTO
    let data: [PurchaseHistoryDTO]
}

struct PurchaseHistoryDTO: Decodable {
    let purchaseQuantity, purchasePrice: Int
    let purchaseDate: String
}

extension PurchaseHistoriesDTO {
    func toPurchaseHistories() -> PurchaseHistories {
        return .init(meta: meta.toMeta(), data: data.map { $0.toPurchaseHistory() } )
    }
}

extension PurchaseHistoryDTO {
    func toPurchaseHistory() -> PurchaseHistory {
        return .init(purchaseQuantity: purchaseQuantity, purchasePrice: purchasePrice, purchaseDate: purchaseDate)
    }
}

