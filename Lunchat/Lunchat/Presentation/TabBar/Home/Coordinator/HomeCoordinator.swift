//
//  HomeCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift

final class HomeCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .home
    private let disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getHomeViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Home

extension HomeCoordinator: HomeViewDelegate {
    
    // Home
    func showNotificationViewController() {
        let viewController = getNotificationViewController()
        self.navigationController.visibleViewController?.setNavBackButton(title: "알림")
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showLocationPermission() {
        let viewController = LocationPermissionAlert()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}

// MARK: - Home Cell

extension HomeCoordinator {
    // CreateAppointmentCellViewModel
    func moveToCreateAppointmentCoordinator() {
        let appointmentCoordinator = CreateAppointmentCoordinator(self.navigationController)
        childCoordinators.append(appointmentCoordinator)
        appointmentCoordinator.delegate = self
        appointmentCoordinator.start()
    }
    
    // AppointmentCellViewModel
    func showAppointmentJoinView(id: String, viewModel: HomeAppointmentCellViewModel) {
        let viewController = AppointmentJoin()
        viewController.modalPresentationStyle = .overFullScreen
    
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                viewModel.joinAppointment(id: id)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.isJoined.take(1).subscribe(onNext: { [weak self] isJoined in
            if isJoined {
                UserStatusTracker.shared.setUserStatus(status: .participated)
                self?.showJoinSuccess()
            } else {
                self?.showJoinFailure()
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showJoinSuccess() {
        let viewController = AppointmentJoinSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name.reloadAppointments, object: nil)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name.reloadAppointments, object: nil)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showJoinFailure() {
        let viewController = AppointmentJoinFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showAppointmentCancelView(viewModel: HomeAppointmentCellViewModel) {
        let viewController = AppointmentCancel()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                viewModel.leaveAppointment()
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.isLeft.subscribe(onNext: { [weak self] isLeft in
            if isLeft {
                UserStatusTracker.shared.setUserStatus(status: .nothing)
                self?.showCancelSuccess()
            } else {
                self?.showCancelFailure()
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showCancelSuccess() {
        let viewController = AppointmentCancelSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showCancelFailure() {
        let viewController = AppointmentCancelFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showAppointmentLeaveView(viewModel: HomeAppointmentCellViewModel) {
        let viewController = AppointmentLeave()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                viewModel.leaveAppointment()
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.isLeft.subscribe(onNext: { [weak self] isLeft in
            if isLeft {
                UserStatusTracker.shared.setUserStatus(status: .nothing)
                self?.showLeaveSuccess()
            } else {
                self?.showLeaveFailure()
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showLeaveSuccess() {
        let viewController = AppointmentLeaveSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showLeaveFailure() {
        let viewController = AppointmentLeaveFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}

// MARK: - Notification

extension HomeCoordinator: NotificationViewDelegate {
    
    func showNotificationAllowAlert() {
        let viewController = NotificationPermissionAlert()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showNotificationNotAllowedAlert() {
        let viewController = NotificationPermissionCancelAlert()
        viewController.modalPresentationStyle = .overFullScreen

        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)

        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}

extension HomeCoordinator {
    
    private func getHomeViewController() -> HomeViewController {
        let appointmentRepository = AppointmentRepository()
        let appointmentUseCase = AppointmentUseCase(appointmentRespository: appointmentRepository)
        
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(userRepository: userRepository)
        
        let homeViewModel = HomeViewModel(userUseCase: userUseCase, appointmentUseCase: appointmentUseCase, delegate: self)
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        
        return homeViewController
    }
    
    private func getNotificationViewController() -> NotificationViewController {
        let notificationRepository = NotificationRepository()
        let notificationUseCase = NotificationUseCase(notificationRepository: notificationRepository)
        
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(userRepository: userRepository)
        
        let notificationViewModel = NotificationViewModel(notificationUseCase: notificationUseCase, userUseCase: userUseCase, delegate: self)
        let notificationViewController = NotificationViewController(viewModel: notificationViewModel)
        
        return notificationViewController
    }
}

extension HomeCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
           if coordinator === childCoordinator {
               childCoordinators.remove(at: index)
               break
           }
       }
    }
}
