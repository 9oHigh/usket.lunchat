//
//  TermsViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/04.
//

import Foundation
import RxSwift

final class TermsViewModel {
    
    private var signupSocial: SignupSocial
    private let authUseCase: AuthUseCase
    private let disposeBag = DisposeBag()
    private weak var termsViewDelegate: TermsViewDelegate?
    
    init(signupSocial: SignupSocial, authUseCase: AuthUseCase, delegate: TermsViewDelegate) {
        self.signupSocial = signupSocial
        self.authUseCase = authUseCase
        self.termsViewDelegate = delegate
    }
    
    func signupWithKakao() {
        authUseCase.signupSign.subscribe({ [weak self] toHome in
            guard let toHome = toHome.element else { return }
            if toHome {
                UserDefaults.standard.setLoginStatus(.login)
                self?.termsViewDelegate?.showSignupSuccess()
            } else {
                self?.termsViewDelegate?.showSignupFailure()
            }
        })
        .disposed(by: disposeBag)
        
        authUseCase.socialSignup(signupSocial: self.signupSocial)
    }
    
    func setAgreeMargeting(isAgree: Bool) {
        self.signupSocial = SignupSocial(authProvider: signupSocial.authProvider, accessToken: signupSocial.accessToken, nickname: signupSocial.nickname, gender: signupSocial.gender, bio: signupSocial.bio, marketingInformationConsent: isAgree)
    }
    
    func showDetailTerm(type: TermType) {
        termsViewDelegate?.showDetailTerm(type: type)
    }
    
    func showInvalidConfirm() {
        termsViewDelegate?.showInvalidConfirm()
    }
}
