//
//  ThreadViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/9/24.
//

import Foundation

protocol ThreadViewDelegate: AnyObject {
    func showNotificationViewController()
    func showThreadDetail(id: String, isShared: Bool)
    func showMyThreadViewController()
    func moveToCreateThreadCoordinator()
}
