//
//  SignUpViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/08.
//

import Foundation
import RxSwift
import RxCocoa

enum SocialLoginType: String {
    case kakao
    case apple
}

final class SignUpViewModel: BaseViewModel {
    
    struct Input {
        let gender: Signal<Bool>
        let introduceText: Signal<String>
        let startSign: Signal<SignupUserInfo>
    }
    
    struct Output {
        let isAvailableNickname: PublishSubject<Bool>
    }
    
    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCase
    private let socialType: SocialLoginType
    private weak var signupViewDelegate: SignupViewDelegate?
    
    private let optionsRelay = BehaviorRelay<[String: Any]>(value: [:])
    private let isAvailableNickname = PublishSubject<Bool>()
    
    var disposeBag = DisposeBag()
    
    init(authUseCase: AuthUseCase, userUseCase: UserUseCase, socialType: SocialLoginType, delegate: SignupViewDelegate) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
        self.socialType = socialType
        self.signupViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {

        input.gender.emit { [weak self] isMan in
            self?.updateOption("gender", with: isMan)
        }.disposed(by: disposeBag)
        
        input.introduceText.emit { [weak self] text in
            if text.isEmpty {
                self?.updateOption("bio", with: false)
            } else {
                self?.updateOption("bio", with: true)
            }
        }.disposed(by: disposeBag)
        
        input.startSign.emit { [weak self] userInfo in
            guard let socialType = self?.socialType else { return }
            let authProvider: String = socialType.rawValue.uppercased()
            let token: String
            switch socialType {
            case .apple:
                token = UserDefaults.standard.getUserInfo(.appleAccessToken) ?? ""
            case .kakao:
                token = UserDefaults.standard.getUserInfo(.kakaoAccessToken) ?? ""
            }
            
            let requsetUserInfo: SignupSocial = SignupSocial(authProvider: authProvider, accessToken: token, nickname: userInfo.nickname, gender: userInfo.gender, bio: userInfo.bio, marketingInformationConsent: true)
            self?.signupViewDelegate?.showTermsViewController(signupWithSocial: requsetUserInfo)
        }
        .disposed(by: disposeBag)
        
        userUseCase.isAvailableNickname.subscribe({ [weak self] available in
            if let available = available.element, available {
                self?.updateOption("nickname", with: true)
                self?.isAvailableNickname.onNext(true)
            } else {
                self?.updateOption("nickname", with: false)
                self?.isAvailableNickname.onNext(false)
            }
        })
        .disposed(by: disposeBag)

        return Output(isAvailableNickname: isAvailableNickname)
    }
    
    func checkAvailableNickname(nickname: String) {
        userUseCase.checkUserNickname(nickname: nickname)
    }
    
    func checkAllOptions() -> Observable<Bool> {
        let nicknameObservable: Observable<Bool> = optionsRelay.map { $0["nickname"] as? Bool }.filter { $0 != nil }.compactMap { $0 }
        let genderObservable: Observable<Bool?> = optionsRelay.map { $0["gender"] as? Bool }.filter { $0 != nil }.compactMap { $0 }
        let bioObservable: Observable<Bool?> = optionsRelay.map { $0["bio"] as? Bool }.filter { $0 != nil }.compactMap { $0 }
        
        let isButtonEnabled = Observable.combineLatest(nicknameObservable, genderObservable, bioObservable, resultSelector: { nickname, gender, bio in
            return nickname && bio! && gender != nil
        })
        return isButtonEnabled
    }
    
    private func updateOption(_ key: String, with value: Any) {
        var currentOptions = optionsRelay.value
        if currentOptions.keys.contains(key) {
            currentOptions[key] = value
        } else {
            currentOptions.merge([key: value], uniquingKeysWith: { (_, new) in new })
        }
        optionsRelay.accept(currentOptions)
    }
    
    func showSigninViewController() {
        signupViewDelegate?.showSigninViewController()
    }
}
