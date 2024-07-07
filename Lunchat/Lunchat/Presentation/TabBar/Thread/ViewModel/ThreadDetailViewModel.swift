//
//  ThreadDetailViewModell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/22.
//

import Foundation
import RxSwift

final class ThreadDetailViewModell {
    
    private let id: String
    private let useCase: ThreadUseCase
    private weak var threadDetailViewDelegate: ThreadDetailViewDelegate?
    private let disposeBag = DisposeBag()
    
    let post = PublishSubject<Post>()
    let isLike = PublishSubject<(Bool, Int)>()
    let disLike = PublishSubject<Bool>()
    
    init(useCase: ThreadUseCase, delegate: ThreadDetailViewDelegate, id: String) {
        self.useCase = useCase
        self.threadDetailViewDelegate = delegate
        self.id = id
    }
    
    func subscribePost() {
        useCase.post.subscribe({ [weak self] post in
            if let post = post.element, let post = post {
                self?.post.onNext(post)
                NotificationCenter.default.post(name: NSNotification.Name.reloadLikedPosts, object: nil)
                NotificationCenter.default.post(name: NSNotification.Name.reloadSharedPosts, object: nil)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func subscribeLike() {
        useCase.post.subscribe({ [weak self] post in
            if let post = post.element, let post = post {
                self?.isLike.onNext((post.isLiked, post.likeCount))
            }
        })
        .disposed(by: disposeBag)
    }
    
    func subscribeDisLike() {
        useCase.post.subscribe({ [weak self] post in
            if let post = post.element, let post = post {
                self?.disLike.onNext(post.isDisliked)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func subScribeDeletePost() {
        useCase.isDeleted.subscribe({ [weak self] isDeleted in
            if let isDeleted = isDeleted.element, isDeleted {
                self?.threadDetailViewDelegate?.showDeleteThreadSuccess()
            } else {
                self?.threadDetailViewDelegate?.showDeleteThreadFailure()
            }
        })
        .disposed(by: disposeBag)
    }
    
    func getAPost() {
        useCase.getAPost(id: id)
    }
    
    func deletePost() {
        useCase.deletePost(id: id)
    }
    
    func setLike(completion: @escaping () -> Void) {
        useCase.setLike(id: id, completion: completion)
    }
    
    func setDisLike(completion: @escaping () -> Void) {
        useCase.setDisLike(id: id, completion: completion)
    }
    
    func getId() -> String {
        return id
    }
    
    // MARK: - Navigation
    
    func showDeleteThread() {
        threadDetailViewDelegate?.showDeleteThreadView {
            self.deletePost()
        }
    }
}
