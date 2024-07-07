//
//  PurchaseHistory.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct PurchaseHistories: Equatable {
    let meta: Meta
    let data: [PurchaseHistory]
}

struct PurchaseHistory: Equatable {
    let purchaseQuantity, purchasePrice: Int
    let purchaseDate: String
}
