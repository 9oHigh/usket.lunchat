//
//  Post.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/21.
//

import Foundation

struct Posts: Equatable {
    let meta: Meta
    let data: [Post]
}

struct Post: Equatable {
    let id: String
    let fileURL: String?
    let title, content: String
    let remainTime: String
    let placeArea, placeTitle, placeAddress, placeRoadAddress: String
    let placeLatitude, placeLongitude: String
    let isLiked: Bool
    let likeCount: Int
    let isDisliked, hidden: Bool
    let author: Author
}

struct Author: Equatable {
    let area: String?
    let nickname: String
    let profilePicture: String
}
