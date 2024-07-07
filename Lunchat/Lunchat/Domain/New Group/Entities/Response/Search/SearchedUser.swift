//
//  SearchedUser.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/14.
//

import Foundation

struct SearchedUsers: Equatable {
    let meta: Meta
    let data: [SearchedUser]
}

struct SearchedUser: Equatable {
    let profilePicture: String
    let nickname: String
    let gender: Bool
    let bio: String
}

extension SearchedUser {
    static var empty: SearchedUser {
        return .init(profilePicture: "", nickname: "", gender: true, bio: "")
    }
}
