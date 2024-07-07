//
//  Meta.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/26.
//

import Foundation

struct MetaDTO: Decodable {
    let page, take, total, lastPage: Int
    let hasPreviousPage, hasNextPage: Bool
}

extension MetaDTO {
    func toMeta() -> Meta {
        return .init(page: page, take: take, total: total, lastPage: lastPage, hasPreviousPage: hasPreviousPage, hasNextPage: hasNextPage)
    }
}
