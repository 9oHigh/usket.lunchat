//
//  AppointmentCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift

final class ThreadCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .thread
    private let disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getThreadViewController()
        self.navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Thread

extension ThreadCoordinator: ThreadViewDelegate, MyThreadViewDelegate {
    
    func showNotificationViewController() {
        let viewController = getNotificationViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "알림")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showThreadDetail(id: String, isShared: Bool = false) {
        let viewController = getThreadDetailViewController(id: id, isShared: isShared)
        navigationController.visibleViewController?.setNavBackButton(title: "쓰레드")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMyThreadViewController() {
        let viewController = getMyThreadViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "내 쓰레드")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func moveToCreateThreadCoordinator() {
        let newThreadCoordinator = CreateThreadCoordinator(self.navigationController)
        childCoordinators.append(newThreadCoordinator)
        newThreadCoordinator.delegate = self
        newThreadCoordinator.start()
    }
}

extension ThreadCoordinator: ThreadDetailViewDelegate {
    
    func showDeleteThreadView(_ completion: @escaping () -> Void) {
        let viewController = DeleteThread()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                completion()
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
    
    func showDeleteThreadSuccess() {
        let viewController = DeleteThreadSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name.reloadSharedPosts, object: nil)
                self?.navigationController.popViewController(animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name.reloadSharedPosts, object: nil)
                self?.navigationController.popViewController(animated: true)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showDeleteThreadFailure() {
        let viewController = DeleteThreadFailure()
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

extension ThreadCoordinator: NotificationViewDelegate {
    
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

extension ThreadCoordinator {
    
    private func getThreadViewController() -> ThreadViewController {
        let repository = ThreadRepository()
        let useCase = ThreadUseCase(repository: repository)
        let viewModel = ThreadViewModel(useCase: useCase, delegate: self)
        let viewController = ThreadViewController(viewModel: viewModel)
        return viewController
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
    
    private func getThreadDetailViewController(id: String, isShared: Bool = false) -> ThreadDetailViewController {
        let repository = ThreadRepository()
        let useCase = ThreadUseCase(repository: repository)
        let viewModel = ThreadDetailViewModell(useCase: useCase, delegate: self, id: id)
        let viewController = ThreadDetailViewController(viewModel: viewModel, isShared: isShared)
        
        return viewController
    }
    
    private func getSharedThreadViewController() -> SharedThreadViewController {
        let repository = ThreadRepository()
        let useCase = ThreadUseCase(repository: repository)
        let viewModel = MyThreadViewModel(useCase: useCase, delegate: self)
        let viewController = SharedThreadViewController(viewModel: viewModel)
        
        return viewController
    }
    
    private func getLikedThreadViewController() -> LikedThreadViewController {
        let repository = ThreadRepository()
        let useCase = ThreadUseCase(repository: repository)
        let viewModel = MyThreadViewModel(useCase: useCase, delegate: self)
        let viewController = LikedThreadViewController(viewModel: viewModel)
        
        return viewController
    }
    
    private func getMyThreadViewController() -> MyThreadViewController {
        let sharedThreadViewController = getSharedThreadViewController()
        let likedThreadViewController = getLikedThreadViewController()
        let viewController = MyThreadViewController(viewControllers: [sharedThreadViewController, likedThreadViewController])
        
        return viewController
    }
}

extension ThreadCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
