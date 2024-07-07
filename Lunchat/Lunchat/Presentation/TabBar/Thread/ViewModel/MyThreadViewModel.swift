//
//  MyThreadViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/25.
//

import Foundation
import RxSwift

final class MyThreadViewModel {
    
    let likedPosts = BehaviorSubject<[Post]>(value: [])
    let sharedPosts = BehaviorSubject<[Post]>(value: [])
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    
    private let useCase: ThreadUseCase
    private let disposeBag = DisposeBag()
    private weak var threadViewDelegate: MyThreadViewDelegate?
    
    init(useCase: ThreadUseCase, delegate: MyThreadViewDelegate) {
        self.useCase = useCase
        self.threadViewDelegate = delegate
    }
    
    func subscribeShared() {
        useCase.posts.subscribe({ [weak self] posts in
            guard let self = self else { return }
            if let posts = posts.element, let posts = posts {
                self.total = posts.meta.total
                self.hasNextPage = posts.meta.hasNextPage

                if posts.data.isEmpty {
                    if self.total != 0 {
                        if let exsting = try? self.sharedPosts.value() {
                            self.sharedPosts.onNext(exsting)
                        }
                    } else {
                        self.sharedPosts.onNext([])
                    }
                } else {
                    if let existing = try? self.sharedPosts.value() {
                        self.sharedPosts.onNext(existing + posts.data)
                    } else {
                        self.sharedPosts.onNext(posts.data)
                    }
                }
            } else {
                self.sharedPosts.onNext([])
            }
        })
        .disposed(by: disposeBag)
    }
    
    func fetchSharedPosts() {
        useCase.getPosts(page: page, take: take, mine: true, liked: false)
    }
    
    func getMoreSharedPosts() {
        if let isLoading = try? self.isLoading.value(), isLoading {
            return
        }
        
        if let posts = try? self.sharedPosts.value(), posts.count > total {
            self.isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        self.page += 1
        
        self.isLoading.onNext(true)
        
        self.useCase.getPosts(page: self.page, take: self.take, mine: true, liked: false) {
            self.isLoading.onNext(false)
        }
    }
    
    func subscribeLiked() {
        useCase.posts.subscribe({ [weak self] posts in
            guard let self = self else { return }
            if let posts = posts.element, let posts = posts {
                self.total = posts.meta.total
                self.hasNextPage = posts.meta.hasNextPage

                if posts.data.isEmpty {
                    if self.total != 0 {
                        if let exsting = try? self.likedPosts.value() {
                            self.likedPosts.onNext(exsting)
                        }
                    } else {
                        self.likedPosts.onNext([])
                    }
                } else {
                    if let existing = try? self.likedPosts.value() {
                        self.likedPosts.onNext(existing + posts.data)
                    } else {
                        self.likedPosts.onNext(posts.data)
                    }
                }
            } else {
                self.likedPosts.onNext([])
            }
        })
        .disposed(by: disposeBag)
    }
    
    func fetchLikedPosts() {
        useCase.getPosts(page: page, take: take, mine: false, liked: true)
    }
    
    func getMoreLikedPosts() {
        if let isLoading = try? self.isLoading.value(), isLoading {
            return
        }
        
        if let posts = try? self.likedPosts.value(), posts.count > total {
            self.isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        self.page += 1
        
        self.isLoading.onNext(true)
        
        self.useCase.getPosts(page: self.page, take: self.take, mine: false, liked: true) {
            self.isLoading.onNext(false)
        }
    }
    
    func setDefaultPageOptions() {
        page = 0
        total = 0
        sharedPosts.onNext([])
        likedPosts.onNext([])
    }
    
    // MARK: - Navigation
    
    func showLikedThreadDetailView(id: String) {
        threadViewDelegate?.showThreadDetail(id: id, isShared: false)
    }
    
    func showSharedThreadDetailView(id: String) {
        threadViewDelegate?.showThreadDetail(id: id, isShared: true)
    }
    
    func moveToCreateThread() {
        threadViewDelegate?.moveToCreateThreadCoordinator()
    }
}
