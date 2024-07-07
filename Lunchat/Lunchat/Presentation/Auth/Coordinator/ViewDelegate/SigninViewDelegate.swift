//
//  SigninViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/8/24.
//

import Foundation

protocol SigninViewDelegate: AnyObject {
    func moveToTabBarCoordinator()
    func showSignupViewController(socialType: SocialLoginType)
    func showSigninFailureKakao()
    func showSigninFailureTemp()
}
