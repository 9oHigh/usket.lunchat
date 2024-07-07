//
//  ThreadRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import Foundation

protocol ThreadRepositoryType {
    func getUserInfo(completion: @escaping (Result<UserInformation?, APIError>) -> Void)
    func getPosts(page: Int, take: Int, mine: Bool, liked: Bool, completion: @escaping (Result<Posts?,APIError>) -> Void)
    func getAPost(id: String, completion: @escaping (Result<Post?, APIError>) -> Void)
    func createPost(fileUrl: String, title: String, content: String, placeTitle: String, placeAddress: String, placeRoadAddress: String, completion: @escaping (APIError?) -> Void)
    func setLike(id: String, completion: @escaping (APIError?) -> Void)
    func setDisLike(id: String, completion: @escaping (APIError?) -> Void)
    func deletePost(id: String, completion: @escaping (APIError?) -> Void)
}
