//
//  AuthCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift

final class AuthCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .auth
    
    private var disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setStartViewController()
    }
    
    private func setStartViewController() {
        
        transitionAnimation()
        
        let isLoggedIn = UserDefaults.standard.getLoginStatus()
        
        if isLoggedIn {
            moveToTabBarCoordinator()
        } else {
            let viewController = getSignInViewController()
            navigationController.pushViewController(viewController, animated: false)
        }
    }
}

// MARK: - Signin

extension AuthCoordinator: SigninViewDelegate {
    
    func showSignupViewController(socialType: SocialLoginType) {
        let viewController = getSignUpViewController(socialType: socialType)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSigninFailureKakao() {
        let viewController = SignInFailureKakao()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.setBind(coordinator: self)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        navigationController.present(viewController, animated: false)
    }
    
    func showSigninFailureTemp() {
        let viewController = SignInFailureTemp()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.setBind(coordinator: self)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        navigationController.present(viewController, animated: false)
    }
}

// MARK: - Signup

extension AuthCoordinator: SignupViewDelegate {
    
    func showSigninViewController() {
        start()
    }
    
    func moveToTabBarCoordinator() {
        let tabBarCoordinator = TabBarCoordinator(self.navigationController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    func showTermsViewController(signupWithSocial info: SignupSocial) {
        let viewController = getTermsViewController(signupSocial: info)
        navigationController.visibleViewController?.setNavBackButton(title: "약관동의")
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Terms

extension AuthCoordinator: TermsViewDelegate {
    
    func showSignupSuccess() {
        let viewController = SignUpSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe({ [weak self] _ in
            viewController.dismiss(animated: true) {
                self?.moveToTabBarCoordinator()
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                self?.moveToTabBarCoordinator()
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showSignupFailure() {
        let viewController = SignUpFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.setBind(coordinator: self)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        navigationController.present(viewController, animated: false)
    }
    
    func showDetailTerm(type: TermType) {
        guard let url = type.url else { return }
        let viewController = getTermsWebViewController(url: url)
        
        viewController.getConfirmObservable().subscribe(onNext:{ [weak self, weak viewController] type in
            guard let type = type else { return }
            NotificationCenter.default.post(name: NSNotification.Name.termType, object: nil, userInfo: ["termType": type])
            self?.navigationController.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
        
        navigationController.visibleViewController?.setNavBackButton(title: type.navigationTitle ?? "")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showInvalidConfirm() {
        let viewController = InvalidConfirm()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckObservable().subscribe(onNext: { [weak self, weak viewController] in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}

extension AuthCoordinator {
    
    private func getSignInViewController() -> SignInViewController {
        let signInRepository = AuthRepository()
        let signInUseCase = AuthUseCase(authRepository: signInRepository)
        let signInViewModel = SignInViewModel(authUseCase: signInUseCase, delegate: self)
        let signInViewController = SignInViewController(viewModel: signInViewModel)
        signInViewController.setNavBackButton(title: "회원가입")
        return signInViewController
    }
    
    private func getSignUpViewController(socialType: SocialLoginType) -> SignUpViewController {
        let authRepository = AuthRepository()
        let userRepository = UserRepository()
        
        let authUseCase = AuthUseCase(authRepository: authRepository)
        let userUserCase = UserUseCase(userRepository: userRepository)
        
        let viewModel = SignUpViewModel(authUseCase: authUseCase, userUseCase: userUserCase, socialType: socialType, delegate: self)
        let signUpViewController = SignUpViewController(viewModel: viewModel)
        
        return signUpViewController
    }
    
    private func getTermsViewController(signupSocial: SignupSocial) -> TermsViewController {
        let authRepository = AuthRepository()
        let authUseCase = AuthUseCase(authRepository: authRepository)
        let viewModel = TermsViewModel(signupSocial: signupSocial, authUseCase: authUseCase, delegate: self)
        let viewController = TermsViewController(viewModel: viewModel)
        return viewController
    }

    private func getTermsWebViewController(url: URL) -> TermsWebViewController {
        let viewController = TermsWebViewController(url: url)
        return viewController
    }
}
