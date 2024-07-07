//
//  ProfileViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SafariServices

final class ProfileViewModel: BaseViewModel {
    
    struct Input {
        let editProfileSign: Signal<Void>?
        let goToShopSign: Signal<Void>?
        let goToSettingSign: Signal<Void>?
        let profileSign: Signal<Void>?
    }
    
    struct Output {
        let profile: PublishSubject<Profile?>
    }
    
    private let profile = PublishSubject<Profile?>()
    
    private weak var profileViewDelegate: ProfileViewDelegate?
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    var disposeBag = DisposeBag()
    
    init(userUseCase: UserUseCase, authUseCase: AuthUseCase, delegate: ProfileViewDelegate?) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.profileViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.editProfileSign?.emit { [weak self] _ in
            guard let self = self else { return }
            self.profileViewDelegate?.showEditProfileViewController()
        }
        .disposed(by: disposeBag)
        
        input.goToShopSign?.emit { [weak self] _ in
            self?.profileViewDelegate?.showShopViewController()
        }
        .disposed(by: disposeBag)
        
        input.goToSettingSign?.emit { [weak self] _ in
            self?.profileViewDelegate?.showSettingViewController()
        }
        .disposed(by: disposeBag)

        input.profileSign?.emit { [weak self] _ in
            self?.userUseCase.getUserInfo()
        }
        .disposed(by: disposeBag)
        
        self.userUseCase.userInfo.subscribe({ [weak self] info in
            guard let userInfo = info.element,
                  let nickname = userInfo?.nickname
            else { return }
            self?.userUseCase.getUserProfile(nickname: nickname)
        })
        .disposed(by: disposeBag)
        
        self.userUseCase.userProfile.subscribe({ [weak self] userProfile in
            guard let profile = userProfile.element,
                  let profile = profile else {
                self?.profile.onNext(nil)
                return
            }
            self?.profile.onNext(profile)
        })
        .disposed(by: disposeBag)

        return Output(profile: profile)
    }
    
    func getUserProfile(nickname: String) {
        userUseCase.getUserProfile(nickname: nickname)
    }
    
    // MARK: - Coordinator
 
    func toSettingViewController() {
        profileViewDelegate?.showSettingViewController()
    }

    func toShopViewController() {
        profileViewDelegate?.showShopViewController()
    }
    
    func toEditProfileViewController() {
        profileViewDelegate?.showEditProfileViewController()
    }
}
