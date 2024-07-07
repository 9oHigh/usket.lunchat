//
//  SignupViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/8/24.
//

import Foundation

protocol SignupViewDelegate: AnyObject {
    func showSigninViewController()
    func showTermsViewController(signupWithSocial info: SignupSocial)
    func moveToTabBarCoordinator()
}
