//
//  SettingViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/12/24.
//

import Foundation

protocol SettingViewDelegate: AnyObject {
    // auth
    func moveToAuthCoordinator()
    
    // feedback
    func showFeedBackViewController(viewModel: SettingViewModel)
    func showFeedBackSuccess()
    func showFeedBackFailure()
    
    // logout
    func showLogoutView(viewModel: SettingViewModel)
    func showLogoutFailure()
    
    // withdrawal
    func showWithdrawalViewController(viewModel: SettingViewModel)
    func showWithdrawalFailure()
    
    // etc
    func showSafariView(url: URL)
    func showOpenSourceViewController()
}
