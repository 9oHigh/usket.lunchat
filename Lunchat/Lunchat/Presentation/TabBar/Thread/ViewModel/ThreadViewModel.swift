//
//  ThreadViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import Foundation
import RxSwift
import RxCocoa

final class ThreadViewModel: BaseViewModel {
    
    struct Input {
        let toNotificationSignal: Signal<Void>
    }
    
    struct Output {
        let posts: BehaviorSubject<[Post]>
        let userInfo: PublishSubject<UserInformation>
    }
    
    private let posts = BehaviorSubject<[Post]>(value: [])
    private let userInfo = PublishSubject<UserInformation>()
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    private let useCase: ThreadUseCase
    private weak var threadViewDelegate: ThreadViewDelegate?
    var disposeBag = DisposeBag()
    
    init(useCase: ThreadUseCase, delegate: ThreadViewDelegate) {
        self.useCase = useCase
        self.threadViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.toNotificationSignal.emit { [weak self] _ in
            self?.threadViewDelegate?.showNotificationViewController()
        }
        .disposed(by: disposeBag)
        
        useCase.userInfo.subscribe({ [weak self] info in
            guard let self = self else { return }
            if let userInfo = info.element, let userInfo = userInfo {
                self.userInfo.onNext(userInfo)
            }
        })
        .disposed(by: disposeBag)
        
        useCase.posts.subscribe({ [weak self] posts in
            guard let self = self else { return }
            if let posts = posts.element, let posts = posts {
                self.total = posts.meta.total
                self.hasNextPage = posts.meta.hasNextPage

                if posts.data.isEmpty {
                    if self.total != 0 {
                        if let exsting = try? self.posts.value() {
                            self.posts.onNext(exsting)
                        }
                    } else {
                        self.posts.onNext([])
                    }
                } else {
                    if let existing = try? self.posts.value() {
                        self.posts.onNext(existing + posts.data)
                    } else {
                        self.posts.onNext(posts.data)
                    }
                }
            } else {
                self.posts.onNext([])
            }
        })
        .disposed(by: disposeBag)

        return Output(posts: posts, userInfo: userInfo)
    }
    
    func getUserInfo() {
        useCase.getUserInfo()
    }
    
    func getPosts() {
        useCase.getPosts(page: page, take: take, mine: false, liked: false)
    }
    
    func getMorePosts() {
        if let isLoading = try? self.isLoading.value(), isLoading {
            return
        }
        
        if let posts = try? self.posts.value(), posts.count > total {
            self.isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        self.page += 1
        
        self.isLoading.onNext(true)
        
        self.useCase.getPosts(page: self.page, take: self.take, mine: false, liked: false) {
            self.isLoading.onNext(false)
        }
    }
    
    func setDefaultPageOptions() {
        page = 0
        total = 0
        posts.onNext([])
    }
    
    // MARK: - Navigation
    
    func showThreadDetail(id: String) {
        threadViewDelegate?.showThreadDetail(id: id, isShared: false)
    }
    
    func moveToCreateThreadCoordinator() {
        threadViewDelegate?.moveToCreateThreadCoordinator()
    }
    
    func showMyThreadViewController() {
        threadViewDelegate?.showMyThreadViewController()
    }
}
