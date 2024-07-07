//
//  NotificationRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation

protocol NotificationRepositoryType: AnyObject {
    func getAllNotification(page: Int, take: Int, completion: @escaping (Result<Notifications?, APIError>) -> Void)
    func getANotification(id: String, completion: @escaping (Result<Notification?, APIError>) -> Void)
    func readNotification(id: String, isRead: Bool, completion: @escaping (APIError?) -> Void)
    func removeNotification(id: String, completion: @escaping (APIError?) -> Void)
}
