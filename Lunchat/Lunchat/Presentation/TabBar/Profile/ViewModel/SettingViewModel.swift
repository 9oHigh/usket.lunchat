//
//  SettingViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/01.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: BaseViewModel {
    
    struct Input {
        let sendFeedbackSignal: Signal<Feedback>?
    }
    
    struct Output {
        
    }
    
    private weak var settingViewDelegate: SettingViewDelegate?
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    private let supportUseCase: SupportUseCase
    var disposeBag = DisposeBag()
    
    init(userUseCase: UserUseCase, authUseCase: AuthUseCase, supportUseCase: SupportUseCase, delegate: SettingViewDelegate?) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.supportUseCase = supportUseCase
        self.settingViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.sendFeedbackSignal?.emit { [weak self] feedback in
            self?.supportUseCase.sendFeedback(feedback: feedback)
        }
        .disposed(by: disposeBag)
        
        supportUseCase.successFeedback.subscribe({ [weak self] isSuccess in
            if let isSuccess = isSuccess.element, isSuccess {
                self?.settingViewDelegate?.showFeedBackSuccess()
            } else {
                self?.settingViewDelegate?.showFeedBackFailure()
            }
        })
        .disposed(by: disposeBag)

        authUseCase.logoutSign.subscribe(onNext: { [weak self] loggedOut in
            if loggedOut {
                self?.settingViewDelegate?.moveToAuthCoordinator()
            } else {
                self?.settingViewDelegate?.showLogoutFailure()
            }
        })
        .disposed(by: disposeBag)
        
        userUseCase.isDeletedUser.subscribe({ [weak self] isDeleted in
            if let isDeleted = isDeleted.element, isDeleted {
                self?.settingViewDelegate?.moveToAuthCoordinator()
            } else {
                self?.settingViewDelegate?.showLogoutFailure()
            }
        })
        .disposed(by: disposeBag)
        
        return Output()
    }
    
    func logout() {
        authUseCase.logout()
    }
    
    func withdrawal(reason: String) {
        userUseCase.deleteUser(reason: reason)
    }
    
    func resetViewModel() {
        disposeBag = DisposeBag()
    }
    
    func moveToAuthCoordinator() {
        settingViewDelegate?.moveToAuthCoordinator()
    }

    func toNextViewController(_ type: SettingCellType) {
        switch type {
        case .feedback(_):
            settingViewDelegate?.showFeedBackViewController(viewModel: self)
        case .notification(let notificationType):
            guard let url = notificationType.url else { return }
            settingViewDelegate?.showSafariView(url: url)
        case .support(let supprotType):
            if let url = supprotType.url {
                settingViewDelegate?.showSafariView(url: url)
            } else {
                settingViewDelegate?.showOpenSourceViewController()
            }
        case .userStatus(let userStatusType):
            switch userStatusType {
            case .logout:
                settingViewDelegate?.showLogoutView(viewModel: self)
            case .withdrawal:
                settingViewDelegate?.showWithdrawalViewController(viewModel: self)
            }
        default:
            break
        }
    }
}
