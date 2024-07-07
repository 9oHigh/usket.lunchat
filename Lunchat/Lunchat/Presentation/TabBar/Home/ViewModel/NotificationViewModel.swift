//
//  NotificationViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/03.
//

import Foundation
import RxSwift
import RxCocoa

final class NotificationViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let notifications: BehaviorSubject<[Notification]>
        let userInfo: BehaviorSubject<UserInformation?>
    }
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    
    private let notifications = BehaviorSubject<[Notification]>(value: [])
    private let userInformation = BehaviorSubject<UserInformation?>(value: nil)
    private weak var delegate: NotificationViewDelegate?
    
    private let notificationUseCase: NotificationUseCase
    private let userUseCase: UserUseCase
    var disposeBag = DisposeBag()
    
    init(notificationUseCase: NotificationUseCase, userUseCase: UserUseCase, delegate: NotificationViewDelegate?) {
        self.notificationUseCase = notificationUseCase
        self.userUseCase = userUseCase
        self.delegate = delegate
    }
    
    func transform(input: Input) -> Output {

        getAllNotifications()
        getUserInfo()
        
        notificationUseCase.notifications.subscribe({ [weak self] notifications in
            if let notifications = notifications.element,
               let notifications = notifications {
                self?.total = notifications.meta.total
                self?.hasNextPage = notifications.meta.hasNextPage
                if let existing = try? self?.notifications.value() {
                    self?.notifications.onNext(existing + notifications.data)
                } else {
                    self?.notifications.onNext(notifications.data)
                }
            }
        })
        .disposed(by: disposeBag)
        
        userUseCase.userInfo.subscribe({ [weak self] userInfo in
            if let userInfo = userInfo.element, let userInformation = userInfo {
                self?.userInformation.onNext(userInformation)
            } else {
                self?.userInformation.onNext(nil)
            }
        })
        .disposed(by: disposeBag)
        
        return Output(notifications: notifications, userInfo: userInformation)
    }
    
    func getAllNotifications() {
        notificationUseCase.getAllNotification(page: self.page, take: self.take)
    }
    
    func getMoreNotifications() {
        
        if let isLoading = try? self.isLoading.value(), isLoading {
            return
        }
        
        if let notifications = try? self.notifications.value(), notifications.count > total {
            return
        }
        
        if !hasNextPage { return }
        
        page += 1
        
        self.isLoading.onNext(true)
        
        notificationUseCase.getAllNotification(page: self.page, take: self.take) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func getUserInfo() {
        userUseCase.getUserInfo()
    }
    
    func setUserNotification(_ allowPushNotification: Bool) {
        userUseCase.setUserNotification(allowPushNotification: allowPushNotification)
    }
    
    // MARK: - Coordinator
    
    func showNotificationAlert() {
        delegate?.showNotificationAllowAlert()
    }
    
    func showNotificationCancelAlert() {
        delegate?.showNotificationNotAllowedAlert()
    }
}
