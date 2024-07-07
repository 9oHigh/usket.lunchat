//
//  UseHistoryDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct UseHistoriesDTO: Decodable {
    let meta: MetaDTO
    let data: [UseHistoryDTO]
}

struct UseHistoryDTO: Decodable {
    let toUserProfilePicture, toUserNickname: String
    let usedAt: String
}

extension UseHistoriesDTO {
    func toUseHistories() -> UseHistories {
        return .init(meta: meta.toMeta(), data: data.map { $0.toUseHistory() })
    }
}

extension UseHistoryDTO {
    func toUseHistory() -> UseHistory {
        return .init(toUserProfilePicture: toUserProfilePicture, toUserNickname: toUserNickname, usedAt: usedAt)
    }
}
