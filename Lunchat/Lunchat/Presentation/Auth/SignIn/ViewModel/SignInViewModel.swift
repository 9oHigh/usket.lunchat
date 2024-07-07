//
//  SignInViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/17.
//

/*
 import GoogleSignIn
 import AuthenticationServices
 */
import Foundation
import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser

final class SignInViewModel: BaseViewModel {
    
    struct Input {
        let kakaoLoginSign: Signal<Void>
    }
    
    struct Output {
        
    }
    
    private let authUseCase: AuthUseCase
    private weak var signinViewDelegate: SigninViewDelegate?
    private var socialType: SocialLoginType = .kakao
    
    private let kakaoLoginStatus = BehaviorSubject<Bool>(value: false)
    var disposeBag = DisposeBag()
    
    init(authUseCase: AuthUseCase, delegate: SigninViewDelegate) {
        self.authUseCase = authUseCase
        self.signinViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.kakaoLoginSign
            .emit { [weak self] _ in
                self?.loginWithKakao()
            }
            .disposed(by: disposeBag)

        authUseCase.loginSign
            .subscribe({ [weak self] toHome in
                if let toHome = toHome.element, toHome {
                    UserDefaults.standard.setLoginStatus(.login)
                    self?.signinViewDelegate?.moveToTabBarCoordinator()
                } else {
                    guard let type = self?.socialType else { return }
                    self?.signinViewDelegate?.showSignupViewController(socialType: type)
                }
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    func loginWithKakao() {
        
        socialType = .kakao
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken ,error) in
                if error != nil {
                    self?.signinViewDelegate?.showSigninFailureTemp()
                } else {
                    guard let accessToken = oauthToken?.accessToken,
                          let refreshToken = oauthToken?.refreshToken
                    else {
                        self?.signinViewDelegate?.showSigninFailureTemp()
                        return
                    }
                    
                    UserDefaults.standard.setUserInfo(.kakaoRefreshToken, data: refreshToken)
                    UserDefaults.standard.setUserInfo(.kakaoAccessToken, data: accessToken)
                    
                    self?.authUseCase.socialLogin(accessToken: accessToken, authProvider: SocialLoginType.kakao.rawValue.uppercased())
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken ,error) in
                if error != nil {
                    self?.signinViewDelegate?.showSigninFailureTemp()
                } else {
                    guard let accessToken = oauthToken?.accessToken,
                          let refreshToken = oauthToken?.refreshToken
                    else {
                        self?.signinViewDelegate?.showSigninFailureTemp()
                        return
                    }
                    
                    UserDefaults.standard.setUserInfo(.kakaoRefreshToken, data: refreshToken)
                    UserDefaults.standard.setUserInfo(.kakaoAccessToken, data: accessToken)
                    
                    self?.authUseCase.socialLogin(accessToken: accessToken, authProvider: SocialLoginType.kakao.rawValue.uppercased())
                }
            }
        }
    }
    
    func loginWithApple(accessToken: String) {
        socialType = .apple
        authUseCase.socialLogin(accessToken: accessToken, authProvider: SocialLoginType.apple.rawValue.uppercased())
    }
    
    /*
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
     */
}
