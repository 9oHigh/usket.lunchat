//
//  SearchedUser.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/14.
//

import Foundation

struct SearchedUsersDTO: Decodable {
    let meta: MetaDTO
    let data: [SearchedUserDTO]
}

struct SearchedUserDTO: Decodable {
    let profilePicture: String
    let nickname: String
    let gender: Bool
    let bio: String
}

extension SearchedUsersDTO {
    func toSearchedUsers() -> SearchedUsers {
        return .init(meta: meta.toMeta(), data: data.map { $0.toSearchedUser() })
    }
}

extension SearchedUserDTO {
    func toSearchedUser() -> SearchedUser {
        return .init(profilePicture: profilePicture, nickname: nickname, gender: gender, bio: bio)
    }
}
