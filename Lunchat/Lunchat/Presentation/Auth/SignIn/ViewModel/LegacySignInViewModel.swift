//
//  SignInViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/05.
//

/*
import Foundation
import RxSwift
import RxCocoa
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

final class SignInViewModel: BaseViewModel {
    
    struct Input {
        let loginSign: Signal<[String]>
        let kakaoLoginSign: Signal<Void>
        let signUpSign: Signal<Void>
    }
    
    struct Output {
        let showToast: Signal<String>
    }
    
    private let authUseCase: AuthUseCase
    private var coordinator: AuthCoordinator?
    var disposeBag = DisposeBag()
    let showToast = PublishRelay<String>()
    
    init(authUseCase: AuthUseCase, coordinator: AuthCoordinator?) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {

        input.loginSign
            .emit { [weak self] user in
                self?.authUseCase.login(email: user[0], password: user[1])
            }
            .disposed(by: disposeBag)
        
        input.kakaoLoginSign
            .emit { [weak self] _ in
                self?.loginWithKakao()
            }
            .disposed(by: disposeBag)
        
        input.signUpSign
            .emit { [weak self] _ in
                self?.coordinator?.showSignUpViewController()
            }
            .disposed(by: disposeBag)
        
        self.authUseCase.loginSign
            .subscribe({ [weak self] isValid in
                if let isValid = isValid.element, isValid {
                    self?.coordinator?.moveToTabBarCoordinator()
                } else {
                    self?.showToast.accept(MessageType.failSignIn.description)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(showToast: showToast.asSignal())
    }
    
    func loginWithApple(accessToken: String) {
        authUseCase.socialLogin(accessToken: accessToken, type: LoginType.apple.rawValue)
    }
    
    func loginWithGoogle(_ withPresenting: UIViewController) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: withPresenting) { [weak self] signInResult, error in
            
            guard error == nil,
                  let signInResult = signInResult
            else { return }
            
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            let refreshToken = user.refreshToken.tokenString
            
            self?.authUseCase.socialLogin(accessToken: accessToken, type: SocialLoginType.google.rawValue)
            
            UserDefaults.standard.setUserInfo(.googleRefreshToken, data: refreshToken)
            UserDefaults.standard.setUserLoginType(.google)
        }
    }
    
    func loginWithKakao() {
        
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let _ = error {
                    self?.showToast.accept(MessageType.failSocialLogin.description)
                } else {
                    let accessToken = oauthToken?.accessToken
                    let refreshToken = oauthToken?.refreshToken
                    
                    self?.authUseCase.socialLogin(accessToken: accessToken!, type: SocialLoginType.kakao.rawValue)
                    
                    UserDefaults.standard.setUserInfo(.kakaoRefreshToken, data: refreshToken!)
                    UserDefaults.standard.setUserLoginType(.kakao)
                }
            }
        } else {
            self.showToast.accept(MessageType.failKakaoLogin.description)
        }
    }
}
*/
