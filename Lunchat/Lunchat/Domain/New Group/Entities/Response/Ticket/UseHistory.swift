//
//  UseHistory.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation

struct UseHistories: Equatable {
    let meta: Meta
    let data: [UseHistory]
}

struct UseHistory: Equatable {
    let toUserProfilePicture, toUserNickname: String
    let usedAt: String
}
