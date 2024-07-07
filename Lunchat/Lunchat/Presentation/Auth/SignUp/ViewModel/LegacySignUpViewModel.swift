//
//  SignUpViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/08.
//

/* 
import Foundation
import RxSwift
import RxCocoa
 
final class SignUpViewModel: BaseViewModel {
    
    struct Input {
        let requestCode: Signal<String>
        let requestVerify: Signal<[String]>
        let passwordSign: Signal<String>
        let repeatPasswordSign: Signal<[String]>
        let nickname: Signal<String>
        let genderSign: Signal<Bool>
        let createUser: Signal<[String]>
    }
    
    struct Output {
        let canDoNext: BehaviorSubject<Bool>
        let showToast: PublishSubject<String>
        let createdUser: BehaviorSubject<Bool>
    }
    
    private let useCase: UserUseCase
    private let coordinator: AuthCoordinator
    var disposeBag = DisposeBag()
    
    private let canDoNext = BehaviorSubject<Bool>(value: false)
    private let showToast = PublishSubject<String>()
    private let createdUser = BehaviorSubject<Bool>(value: false)
    private var checkSignUp = [String: Bool]()
    
    init(useCase: UserUseCase, coordinator: AuthCoordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {

        input.requestCode
            .emit { [weak self] email in
                self?.useCase.requestEmailCode(recipientEmail: email)
            }
            .disposed(by: disposeBag)
 
        self.useCase.isAvailableSendCode
            .subscribe({ [weak self] isAvailable in
                guard let isAvailable = isAvailable.element, isAvailable else {
                    self?.showToast.onNext(MessageType.inValidEmail.description)
                    return
                }
            })
            .disposed(by: disposeBag)
        
        input.requestVerify
            .emit { [weak self] userInfo in
                self?.useCase.isVerifyEmailCode(email: userInfo[0], code: userInfo[1])
            }
            .disposed(by: disposeBag)
        
        self.useCase.isVerifiedCode
            .subscribe({ [weak self] isVerified in
                guard let isVerified = isVerified.element, isVerified else {
                    self?.showToast.onNext(MessageType.inValidCode.description)
                    self?.checkSignUp["email"] = false
                    return
                }
                
                self?.checkSignUp["email"] = true
                self?.canDoNext.onNext(self?.checkAllUserInfo() ?? false)
            })
            .disposed(by: disposeBag)
        
        input.passwordSign
            .emit { [weak self] password in
                self?.useCase.isAvailablePassword(password: password)
            }
            .disposed(by: disposeBag)
        
        self.useCase.isAvailablePassword
            .subscribe({ [weak self] isAvailable in
                if let isAvailable = isAvailable.element, isAvailable {
                    
                } else {
                    self?.showToast.onNext(MessageType.inValidPassword.description)
                }
            })
            .disposed(by: disposeBag)
        
        input.repeatPasswordSign
            .emit { [weak self] repeatPassword in
                
                if repeatPassword[0] == repeatPassword[1] {
                    self?.checkSignUp["password"] = true
                } else {
                    self?.showToast.onNext(MessageType.notMatchedPassword.description)
                    self?.checkSignUp["password"] = false
                }
                
                self?.canDoNext.onNext(self?.checkAllUserInfo() ?? false)
            }
            .disposed(by: disposeBag)
        
        input.nickname
            .filter { $0 != "" }
            .debounce(.seconds(1))
            .emit { [weak self] nickname in
                // 추후에 불가능한 닉네임 확인해서 선별해야함
                // Usecase에 가능한 닉네임 선별 로직 생성
                self?.useCase.isAvailableNickname(nickname: nickname)
            }
            .disposed(by: disposeBag)
        
        self.useCase.isAvailableNickname
            .subscribe({ [weak self] isAvailable in
                if let isAvailable = isAvailable.element, isAvailable {
                    self?.checkSignUp["nickname"] = true
                } else {
                    self?.showToast.onNext(MessageType.inValidNickname.description)
                    self?.checkSignUp["nickname"] = false
                }
                
                self?.canDoNext.onNext(self?.checkAllUserInfo() ?? false)
            })
            .disposed(by: disposeBag)
        
        input.genderSign
            .emit { [weak self] gender in
                let gender = gender ? "true" : "false"
                self?.checkSignUp["gender"] = true
                self?.canDoNext.onNext(self?.checkAllUserInfo() ?? false)
                
                UserDefaults.standard.setUserInfo(.gender, data: gender)
            }
            .disposed(by: disposeBag)
        
        input.createUser
            .emit { [weak self] elements in

                let email = elements[0]
                let password = elements[1]
                let nickname = elements[2]
                let gender = UserDefaults.standard.getUserInfo(.gender).map { $0 == "true" ? true : false } ?? false
                
                self?.useCase.createUser(email: email, password: password, nickname: nickname, gender: gender)
            }
            .disposed(by: disposeBag)
        
        useCase.isCreatedUser
            .subscribe({ [weak self] user in
                
                if let user = user.element, user != nil {
                    self?.showToast.onNext(MessageType.completeSignUp.description)
                    self?.createdUser.onNext(true)
                    /*
                     UserDefaults.standard.setUserInfo(.email, data: user!.email)
                     UserDefaults.standard.setUserInfo(.password, data: user!.password)
                     */
                    UserDefaults.standard.setUserInfo(.nickname, data: user!.nickname)
                    UserDefaults.standard.setUserInfo(.gender, data: user!.gender ? "true" : "false")
                } else {
                    self?.showToast.onNext(MessageType.failedSignUp.description)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(canDoNext: canDoNext, showToast: showToast, createdUser: createdUser)
    }
    
    func toSignInViewController() {
        coordinator.showSignInViewController()
    }
    
    private func checkAllUserInfo() -> Bool {
        
        if self.checkSignUp.count == 4 && self.checkSignUp.filter({ $0.value == true }).count == 4 {
            return true
        }
        return false
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isAvailablePassword(password: String) -> Bool {
        let pattern = "(?=.*[0-9])(?=.*[a-z])(?=.*[~!@#\\$%\\^&\\*]).{8,25}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: password.count)
        let isAvailable = regex.numberOfMatches(in: password, range: range) == 1 ? true : false
        return isAvailable
    }
    
    func isAvailableNickname(_ nickname: String) -> Bool {
        let pattern = "^[가-힣a-zA-Z]{2,12}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: nickname.count)
        let isAvailable = regex.numberOfMatches(in: nickname, range: range) == 1 ? true : false
        return isAvailable
    }
}
*/
