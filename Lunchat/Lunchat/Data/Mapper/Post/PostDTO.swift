//
//  Post.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/21.
//

import Foundation

struct PostsDTO: Decodable {
    let meta: MetaDTO
    let data: [PostDTO]
}

struct PostDTO: Decodable {
    let id: String
    let fileURL: String?
    let title, content: String
    let createdAt: String
    let placeArea, placeTitle, placeAddress, placeRoadAddress: String
    let placeLatitude, placeLongitude: String
    let isLiked: Bool
    let likeCount: Int
    let isDisliked, hidden: Bool
    let author: AuthorDTO

    enum CodingKeys: String, CodingKey {
        case id
        case fileURL = "fileUrl"
        case title, content, createdAt, placeArea, placeTitle, placeAddress, placeRoadAddress, placeLatitude, placeLongitude, isLiked, likeCount, isDisliked, hidden, author
    }
}

struct AuthorDTO: Decodable {
    let area: String?
    let nickname: String
    let profilePicture: String
}

extension PostsDTO {
    func toPosts() -> Posts {
        return .init(meta: meta.toMeta(), data: data.map { $0.toPost() })
    }
}

extension PostDTO {
    func toPost() -> Post {
        return .init(id: id, fileURL: fileURL, title: title, content: content, remainTime: createdAt.timeAgo, placeArea: placeArea, placeTitle: placeTitle, placeAddress: placeAddress, placeRoadAddress: placeRoadAddress, placeLatitude: placeLatitude, placeLongitude: placeLongitude, isLiked: isLiked, likeCount: likeCount, isDisliked: isDisliked, hidden: hidden, author: author.toAuthor())
    }
}

extension AuthorDTO {
    func toAuthor() -> Author {
        return .init(area: area, nickname: nickname, profilePicture: profilePicture)
    }
}
