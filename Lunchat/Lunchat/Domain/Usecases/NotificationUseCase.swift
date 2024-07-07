//
//  NotificationUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import RxSwift

final class NotificationUseCase {
    
    private let notificationRepository: NotificationRepositoryType
    let notifications = PublishSubject<Notifications?>()
    let notification = PublishSubject<Notification?>()
    let isReadSuccess = PublishSubject<Bool>()
    let isRemoved = PublishSubject<Bool>()
    
    init(notificationRepository: NotificationRepositoryType) {
        self.notificationRepository = notificationRepository
    }
    
    func getAllNotification(page: Int, take: Int, completion: @escaping () -> Void = { }) {
        
        notificationRepository.getAllNotification(page: page, take: take) { [weak self] result in
            switch result {
            case .success(let notifications):
                if let notifications = notifications {
                    self?.notifications.onNext(notifications)
                } else {
                    self?.notifications.onNext(nil)
                }
            case .failure(_):
                self?.notifications.onNext(nil)
            }
        }
    }
    
    func getANotification(id: String) {
        
        notificationRepository.getANotification(id: id) { [weak self] result in
            switch result {
            case .success(let notification):
                if let notification = notification {
                    self?.notification.onNext(notification)
                } else {
                    self?.notification.onNext(nil)
                }
            case .failure(_):
                self?.notification.onNext(nil)
            }
        }
    }
    
    func readNotification(id: String, isRead: Bool) {
        
        notificationRepository.readNotification(id: id, isRead: isRead) { [weak self] error in
            if let error = error {
                self?.isReadSuccess.onNext(false)
            } else {
                self?.isReadSuccess.onNext(true)
            }
        }
    }
    
    func removeNotification(id: String) {
        
        notificationRepository.removeNotification(id: id) { [weak self] error in
            if let error = error {
                self?.isRemoved.onNext(false)
            } else {
                self?.isRemoved.onNext(true)
            }
        }
    }
}
