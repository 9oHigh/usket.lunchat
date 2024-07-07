//
//  NotificationViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/8/24.
//

import Foundation

protocol NotificationViewDelegate: AnyObject {
    func showNotificationAllowAlert()
    func showNotificationNotAllowedAlert()
}
