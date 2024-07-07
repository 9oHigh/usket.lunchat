//
//  SearchUserViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/15.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchUserViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let users: BehaviorSubject<[SearchedUser]>
    }
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    private var nickname: String?
    private let users = BehaviorSubject<[SearchedUser]>(value: [])
    
    private let useCase: SearchUseCase
    private weak var profileBottomSheetDelegate: ProfileBottomSheetDelegate?
    var disposeBag = DisposeBag()
    
    init(useCase: SearchUseCase, delegate: ProfileBottomSheetDelegate) {
        self.useCase = useCase
        self.profileBottomSheetDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        self.useCase.users.subscribe({ [weak self] users in
            if let users = users.element, let users = users {
                
                self?.total = users.meta.total
                self?.hasNextPage = users.meta.hasNextPage
                
                if users.data.isEmpty {
                    if self?.total != 0, let existing = try? self?.users.value() {
                        self?.users.onNext(existing)
                    } else {
                        self?.users.onNext([])
                    }
                } else {
                    if let existing = try? self?.users.value() {
                        self?.users.onNext(existing + users.data)
                    } else {
                        self?.users.onNext(users.data)
                    }
                }
            } else {
                self?.users.onNext([])
            }
        })
        .disposed(by: disposeBag)
        
        return Output(users: users)
    }
    
    func showUserProfile(nickname: String) {
        profileBottomSheetDelegate?.showUserProfileView(nickname: nickname)
    }
    
    func getUsers(nickname: String) {
        
        self.nickname = nickname
        
        useCase.searchUser(page: page,
                           take: take,
                           nickname: nickname) { }
    }
    
    func getMoreUsers() {
        
        if let isLoading = try? self.isLoading.value(), isLoading {
            return
        }
        
        if let users = try? self.users.value(), users.count > total {
            self.isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        page += 1
        
        isLoading.onNext(true)
        
        useCase.searchUser(page: page, take: take, nickname: nickname ?? "") { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func setDefaultPageOptions() {
        page = 0
        total = 0
        nickname = nil
        users.onNext([.empty])
    }
}
