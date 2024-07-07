//
//  UserInfoAvailableDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/15.
//

import Foundation

struct NicknameAvailableDTO: Decodable {
    let isAvailable: Bool
}

extension NicknameAvailableDTO {
    func toObject() -> NicknameAvailable {
        return .init(isAvailable: isAvailable)
    }
}
