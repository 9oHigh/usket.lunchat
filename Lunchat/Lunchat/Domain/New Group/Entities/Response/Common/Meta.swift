//
//  Meta.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/26.
//

import Foundation

// MARK: - Meta
struct Meta: Equatable {
    let page, take, total, lastPage: Int
    let hasPreviousPage, hasNextPage: Bool
}
