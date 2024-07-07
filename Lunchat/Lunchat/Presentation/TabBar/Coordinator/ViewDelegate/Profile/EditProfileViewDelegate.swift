//
//  EditProfileViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/12/24.
//

import Foundation

protocol EditProfileViewDelegate: AnyObject {
    func showProfileStoreView(viewModel: EditProfileViewModel, userInfo: [String: Any])
    func showProfileStoreSuccess()
    func showProfileStoreFailure()
}
