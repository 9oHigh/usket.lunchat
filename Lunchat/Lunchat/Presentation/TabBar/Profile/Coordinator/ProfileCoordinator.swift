//
//  ProfileCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift
import SafariServices

final class ProfileCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .profile
    
    private let disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getProfileViewController()
        viewController.unSetNavBackButton(title: "내 프로필")
        self.navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Profile

extension ProfileCoordinator: ProfileViewDelegate {
    
    func showShopViewController() {
        let viewController = getShopViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "상품")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSettingViewController() {
        let viewController = getSettingViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "설정 및 개인 정보")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEditProfileViewController() {
        let viewController = getEditProfileViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "프로필 수정")
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Edit Profile

extension ProfileCoordinator: EditProfileViewDelegate {
    
    func showProfileStoreView(viewModel: EditProfileViewModel, userInfo: [String: Any]) {
        let viewController = ProfileStore()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            guard let self = self else { return }
            viewModel.updateUserInfo(updateInfo: userInfo)
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }

        navigationController.present(viewController, animated: false)
    }
    
    func showProfileStoreSuccess() {
        let viewController = ProfileSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showProfileStoreFailure() {
        let viewController = ProfileFailure()
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

// MARK: - Setting

extension ProfileCoordinator: SettingViewDelegate {
    
    // auth
    func moveToAuthCoordinator() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        sceneDelegate?.restart()
        UserDefaults.standard.setLoginStatus(.logout)
    }
    
    // feedback
    func showFeedBackViewController(viewModel: SettingViewModel) {
        let viewController = FeedbackViewController(viewModel: viewModel)
        navigationController.visibleViewController?.setNavBackButton(title: "피드백 남기기")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showFeedBackSuccess() {
        let viewController = FeedbackSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showFeedBackFailure() {
        let viewController = FeedbackFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                self?.navigationController.popViewController(animated: true)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    // logout
    func showLogoutView(viewModel: SettingViewModel) {
        let input = SettingViewModel.Input(sendFeedbackSignal: nil)
        _ = viewModel.transform(input: input)

        let viewController = UserLogout()
        viewController.modalPresentationStyle = .overFullScreen

        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
            viewModel.logout()
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showLogoutFailure() {
        let viewController = UserLogoutFailure()
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
    
    // withdrawal
    func showWithdrawalViewController(viewModel: SettingViewModel) {
        let viewController = WithdrawalViewController(viewModel: viewModel)
        navigationController.visibleViewController?.setNavBackButton(title: "회원탈퇴")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWithdrawalFailure() {
        let viewController = UserWithdrawalFailure()
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
    
    // etc
    func showSafariView(url: URL) {
        let webView = SFSafariViewController(url: url)
        webView.modalPresentationStyle = .overFullScreen
        navigationController.present(webView, animated: true)
    }
    
    func showOpenSourceViewController() {
        let viewController = OpenSourceViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "오픈소스 라이선스")
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Shop

extension ProfileCoordinator: ShopViewDelegate {
    
    func showTicketCreateView(ticket: TicketType, viewModel: PurchaseViewModel) {
        let viewController = NoteTicketCreate()
        viewController.setNoteCount(ticket.rawValue)
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            NotificationCenter.default.post(name: NSNotification.Name.addLoadingView, object: nil)
            viewModel.currentProductId = ProductId.allCases[ticket.indexPath]
            viewModel.buyProduct(productID: ProductId.allCases[ticket.indexPath].rawValue)
            viewController?.dismiss(animated: true)
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
    
    func showTicketCreateSuccess() {
        let viewController = NoteTicketCreateSuccess()
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
    
    func showTicketCreateFailure() {
        let viewController = NoteTicketCreateFailure()
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

extension ProfileCoordinator {
    
    private func getProfileViewController() -> ProfileViewController {
        let userRepository = UserRepository()
        let userUsecase = UserUseCase(userRepository: userRepository)
        let authRepository = AuthRepository()
        let authUsecase = AuthUseCase(authRepository: authRepository)
        
        let profileViewModel = ProfileViewModel(userUseCase: userUsecase, authUseCase: authUsecase, delegate: self)
        let profileViewController = ProfileViewController(viewModel: profileViewModel)
        
        return profileViewController
    }
    
    private func getSettingViewController() -> SettingViewController {
        let userRepository = UserRepository()
        let userUsecase = UserUseCase(userRepository: userRepository)
        let authRepository = AuthRepository()
        let authUsecase = AuthUseCase(authRepository: authRepository)
        let supportRepository = SupportRepository()
        let supportUseCase = SupportUseCase(supportRepository: supportRepository)
        
        let settingViewModel = SettingViewModel(userUseCase: userUsecase, authUseCase: authUsecase, supportUseCase: supportUseCase, delegate: self)
        let viewController = SettingViewController(viewModel: settingViewModel)
        
        return viewController
    }
    
    private func getEditProfileViewController() -> EditProfileViewController {
        let userRepository = UserRepository()
        let userUsecase = UserUseCase(userRepository: userRepository)
        let fileRepository = FileRepository()
        let fileUsecase = FileUseCase(fileRepository: fileRepository)
        
        let editProfileViewModel = EditProfileViewModel(fileUseCase: fileUsecase, userUseCase: userUsecase, delegate: self)
        let viewController = EditProfileViewController(viewModel: editProfileViewModel)
        
        return viewController
    }
    
    private func getShopViewController() -> ShopViewController {
        let paymentRepository = PaymentRepository()
        let paymentUseCase = PaymentUseCase(paymentRepository: paymentRepository)
        
        let ticketRepository = TicketRepository()
        let ticketUseCase = TicketUseCase(ticketRepository: ticketRepository)
        
        let purchaseViewModel = PurchaseViewModel(paymentUseCase: paymentUseCase, ticketUseCase: ticketUseCase, delegate: self)
        let purchaseHistoryViewModel = PurchaseHistoryViewModel(useCase: ticketUseCase)
        let useHistoryViewModel = UseHistoryViewModel(useCase: ticketUseCase)
        
        let purchaseViewController = PurchaseViewController(viewModel: purchaseViewModel)
        let purchaseHistoryViewController = PurchaseHistoryViewController(viewModel: purchaseHistoryViewModel)
        let useHistoryViewController = UseHistoryViewController(viewModel: useHistoryViewModel)
        
        let shopViewController = ShopViewController(viewControllers: [purchaseViewController, purchaseHistoryViewController, useHistoryViewController])
        return shopViewController
    }
}

extension ProfileCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
           if coordinator === childCoordinator {
               childCoordinators.remove(at: index)
               break
           }
       }
    }
}
