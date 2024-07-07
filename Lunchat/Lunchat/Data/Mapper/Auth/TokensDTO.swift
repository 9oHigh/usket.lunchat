//
//  TokensDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/21.
//

import Foundation

struct TokensDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

extension TokensDTO {
    func toObject() -> Tokens {
        return .init(accessToken: accessToken, refreshToken: refreshToken)
    }
}
