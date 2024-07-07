//
//  ThreadUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/21.
//

import Foundation
import RxSwift

final class ThreadUseCase {
    
    private let repository: ThreadRepositoryType
    let userInfo = PublishSubject<UserInformation?>()
    let posts = PublishSubject<Posts?>()
    let post = PublishSubject<Post?>()
    let isCreatedPost = PublishSubject<Bool>()
    let isLiked = PublishSubject<Bool>()
    let isDisLiked = PublishSubject<Bool>()
    let isDeleted = PublishSubject<Bool>()
    
    init(repository: ThreadRepositoryType) {
        self.repository = repository
    }
    
    func getUserInfo() {
        
        repository.getUserInfo { [weak self] result in
            switch result {
            case .success(let userInfo):
                if let userInfo = userInfo {
                    self?.userInfo.onNext(userInfo)
                } else {
                    self?.userInfo.onNext(nil)
                }
            case .failure(_):
                self?.userInfo.onNext(nil)
            }
        }
    }
    
    func getPosts(page: Int, take: Int, mine: Bool, liked: Bool, completion: @escaping () -> Void = { }) {
        
        repository.getPosts(page: page, take: take, mine: mine, liked: liked) { [weak self] result in
            switch result {
            case .success(let posts):
                if let posts = posts {
                    self?.posts.onNext(posts)
                } else {
                    self?.posts.onNext(nil)
                }
            case .failure(_):
                self?.posts.onNext(nil)
            }
            completion()
        }
    }
    
    func getAPost(id: String) {
        
        repository.getAPost(id: id) { [weak self] result in
            switch result {
            case .success(let post):
                if let post = post {
                    self?.post.onNext(post)
                } else {
                    self?.post.onNext(nil)
                }
            case .failure(_):
                self?.post.onNext(nil)
            }
        }
    }
    
    func createPost(fileUrl: String, title: String, content: String, placeTitle: String, placeAddress: String, placeRoadAddress: String) {
        
        repository.createPost(fileUrl: fileUrl, title: title, content: content, placeTitle: placeTitle, placeAddress: placeAddress, placeRoadAddress: placeRoadAddress) { [weak self] error in
            if error == nil {
                self?.isCreatedPost.onNext(true)
            } else {
                self?.isCreatedPost.onNext(false)
            }
        }
    }
    
    func setLike(id: String, completion: @escaping () -> Void) {
        
        repository.setLike(id: id) { [weak self] error in
            if error == nil {
                self?.isLiked.onNext(true)
            } else {
                self?.isLiked.onNext(false)
            }
            completion()
        }
    }
    
    func setDisLike(id: String, completion: @escaping () -> Void) {
        
        repository.setDisLike(id: id) { [weak self] error in
            if error == nil {
                self?.isDisLiked.onNext(true)
            } else {
                self?.isDisLiked.onNext(false)
            }
            completion()
        }
    }
    
    func deletePost(id: String) {
        
        repository.deletePost(id: id) { [weak self] error in
            if error == nil {
                self?.isDeleted.onNext(true)
            } else {
                self?.isDeleted.onNext(false)
            }
        }
    }
}
