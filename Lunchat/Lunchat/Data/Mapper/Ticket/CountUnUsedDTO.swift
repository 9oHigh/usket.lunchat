//
//  CountUnUsed.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct CountUnUsedDTO: Decodable {
    let ticketCount: Int
}

extension CountUnUsedDTO {
    func toCountUnUed() -> CountUnUsed {
        return .init(ticketCount: ticketCount)
    }
}
