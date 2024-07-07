//
//  SignUpViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/08.
//

/*
import UIKit
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {
    
    private let viewModel: SignUpViewModel
    private let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    
    // Email
    private let emailLabel = UILabel()
    private let emailTextField = SignUpEmailTextField()
    private let emailCodeTextField = SignUpAuthCodeTextField()
    private let emailErrorMessageLabel = UILabel()
    
    // Password
    private let pwdLabel = UILabel()
    private let pwdTextField = SignUpPasswordTextField()
    private let checkPwdTextField = SignUpRepeatPasswordTextField()
    private let passwordErrorMessageLabel = UILabel()
    
    // Nickname
    private let nickNameLabel = UILabel()
    private let nickNameTextField = NicknameTextField()
    private let nickNameErrorMessageLabel = UILabel()
    
    // Gender
    private let genderLabel = UILabel()
    private let manButton = LunchatButton()
    private let womanButton = LunchatButton()
    private let signUpButton = LunchatButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
        bind()
    }
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        
        let manSign = manButton.rx.tap.map { true }.asSignal(onErrorJustReturn: true)
        let womanSign = womanButton.rx.tap.map { false }.asSignal(onErrorJustReturn: false)
        let sign = Signal.merge(manSign, womanSign)
        
        let input = SignUpViewModel.Input(
            requestCode: emailTextField.getSendButtonObservable().map {
                self.emailTextField.text ?? ""
            }.asSignal(onErrorJustReturn: ""),
            requestVerify: emailCodeTextField.getAuthButtonObservable().map {[
                self.emailTextField.text ?? "",
                self.emailCodeTextField.text ?? ""
            ]}.asSignal(onErrorJustReturn: ["", ""]),
            passwordSign: pwdTextField.rx.controlEvent(.editingDidEnd).map {
                self.pwdTextField.text ?? ""
            }.asSignal(onErrorJustReturn: ""),
            repeatPasswordSign: checkPwdTextField.rx.controlEvent(.editingDidEnd).map {
                [self.pwdTextField.text ?? "",
                self.checkPwdTextField.text ?? ""]
            }.asSignal(onErrorJustReturn: []),
            nickname: nickNameTextField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            genderSign: sign,
            createUser: signUpButton.rx.tap.map {[
                self.emailTextField.text ?? "",
                self.pwdTextField.text ?? "",
                self.nickNameTextField.text ?? ""
            ]}.asSignal(onErrorJustReturn: [])
        )

        let output = viewModel.transform(input: input)
 
        output.canDoNext
            .subscribe({ [weak self] doNext in
                if let doNext = doNext.element, doNext {
                    self?.signUpButton.setActive()
                    self?.signUpButton.isUserInteractionEnabled = doNext
                } else {
                    self?.signUpButton.setInActive()
                    self?.signUpButton.isUserInteractionEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        output.showToast
            .subscribe({ [weak self] message in
                guard let message = message.element else { return }
                self?.view.showToast(message)
            })
            .disposed(by: disposeBag)
        
        output.createdUser
            .subscribe({ [weak self] isCreated in
                if let isCreated = isCreated.element, isCreated {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self,
                      let text = text.element, text != "" else { return }
                if !self.viewModel.isValidEmail(text) && self.emailTextField.isEditing {
                    self.emailTextField.setError()
                    self.emailErrorMessageLabel.text = MessageType.inValidEmailForm.description
                } else if self.viewModel.isValidEmail(text) {
                    self.emailTextField.setNomal()
                    self.emailErrorMessageLabel.text = ""
                } else {
                    self.emailErrorMessageLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .subscribe({ [weak self] _ in
                self?.emailErrorMessageLabel.text = ""
            })
            .disposed(by: disposeBag)
        
        pwdTextField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self,
                      let text = text.element, text != "" else {
                    self?.pwdTextField.setNomal()
                    return
                }
                if !self.viewModel.isAvailablePassword(password: text) && self.pwdTextField.isEditing {
                    self.pwdTextField.setError()
                    self.passwordErrorMessageLabel.text = MessageType.inValidPassword.description
                } else if self.viewModel.isAvailablePassword(password: text) {
                    self.pwdTextField.setCheck()
                    self.passwordErrorMessageLabel.text = ""
                } else {
                    self.passwordErrorMessageLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
        
        pwdTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .subscribe({ [weak self] _ in
                self?.passwordErrorMessageLabel.text = ""
            })
            .disposed(by: disposeBag)
        
        checkPwdTextField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self,
                      let text = text.element, text != "" else {
                    self?.checkPwdTextField.setNomal()
                    return
                }
                if self.checkPwdTextField.isEditing && self.pwdTextField.text != text {
                    self.checkPwdTextField.setError()
                    self.passwordErrorMessageLabel.text = MessageType.notMatchedPassword.description
                } else if self.viewModel.isAvailablePassword(password: text) && self.pwdTextField.text == text {
                    self.checkPwdTextField.setCheck()
                    self.passwordErrorMessageLabel.text = ""
                } else {
                    self.passwordErrorMessageLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
        
        checkPwdTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .subscribe({ [weak self] _ in
                self?.passwordErrorMessageLabel.text = ""
            })
            .disposed(by: disposeBag)
        
        nickNameTextField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self,
                      let text = text.element, text != "" else {
                    self?.nickNameTextField.setNomal()
                    return
                }
                if !self.viewModel.isAvailableNickname(text) && self.nickNameTextField.isEditing {
                    self.nickNameTextField.setError()
                    self.nickNameErrorMessageLabel.text = MessageType.inValidNickname.description
                } else if self.viewModel.isAvailableNickname(text) {
                    self.nickNameTextField.setCheck()
                    self.nickNameErrorMessageLabel.text = ""
                } else {
                    self.nickNameErrorMessageLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
        
        nickNameTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .subscribe({ [weak self] _ in
                self?.nickNameErrorMessageLabel.text = ""
            })
            .disposed(by: disposeBag)
        
        manButton.rx.tap
            .subscribe({ [weak self] _ in
                self?.manButton.setActive()
                self?.womanButton.setInActive()
            })
            .disposed(by: disposeBag)
        
        womanButton.rx.tap
            .subscribe({ [weak self] _ in
                self?.manButton.setInActive()
                self?.womanButton.setActive()
            })
            .disposed(by: disposeBag)
    }
}
extension SignUpViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setConfig() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        scrollView.addGestureRecognizer(tapGesture)
        
        emailLabel.text = "로그인을 위한 이메일을 입력해 주세요"
        emailLabel.font = AppFont.shared.getBoldFont(size: 14)
        emailErrorMessageLabel.font = AppFont.shared.getBoldFont(size: 10)
        emailErrorMessageLabel.textColor = AppColor.red.color
        
        pwdLabel.text = "비밀번호를 입력해 주세요."
        pwdLabel.font = AppFont.shared.getBoldFont(size: 14)
        passwordErrorMessageLabel.font = AppFont.shared.getBoldFont(size: 10)
        passwordErrorMessageLabel.textColor = AppColor.red.color

        nickNameLabel.text = "닉네임을 입력해 주세요"
        nickNameLabel.font = AppFont.shared.getBoldFont(size: 14)
        nickNameErrorMessageLabel.font = AppFont.shared.getBoldFont(size: 10)
        nickNameErrorMessageLabel.textColor = AppColor.red.color
        
        genderLabel.text = "성별을 선택해주세요"
        genderLabel.font = AppFont.shared.getBoldFont(size: 14)
        
        manButton.setTitle("남자", for: .normal)
        manButton.backgroundColor = AppColor.inActive.color
        manButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 18)
        
        womanButton.setTitle("여자", for: .normal)
        womanButton.backgroundColor = AppColor.inActive.color
        womanButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 18)
        
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.backgroundColor = AppColor.inActive.color
        signUpButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 18)
    }
    
    private func setUI() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(emailLabel)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(emailCodeTextField)
        scrollView.addSubview(emailErrorMessageLabel)
        
        scrollView.addSubview(pwdLabel)
        scrollView.addSubview(pwdTextField)
        scrollView.addSubview(checkPwdTextField)
        scrollView.addSubview(passwordErrorMessageLabel)
        
        scrollView.addSubview(nickNameLabel)
        scrollView.addSubview(nickNameTextField)
        scrollView.addSubview(nickNameErrorMessageLabel)
        
        scrollView.addSubview(genderLabel)
        scrollView.addSubview(manButton)
        scrollView.addSubview(womanButton)
        scrollView.addSubview(signUpButton)
    }
    
    private func setConstraint() {

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(emailTextField.snp.leading).offset(5)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.067)
        }
        
        emailCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.067)
        }
        
        emailErrorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emailCodeTextField.snp.bottom).offset(1)
            make.leading.equalTo(emailCodeTextField.snp.leading).offset(5)
        }
        
        pwdLabel.snp.makeConstraints { make in
            make.top.equalTo(emailCodeTextField.snp.bottom).offset(28)
            make.leading.equalTo(emailCodeTextField.snp.leading).offset(5)
        }
        
        pwdTextField.snp.makeConstraints { make in
            make.top.equalTo(pwdLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.067)
        }
        
        checkPwdTextField.snp.makeConstraints { make in
            make.top.equalTo(pwdTextField.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.067)
        }
        
        passwordErrorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(checkPwdTextField.snp.bottom).offset(1)
            make.leading.equalTo(checkPwdTextField.snp.leading).offset(5)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(checkPwdTextField.snp.bottom).offset(28)
            make.leading.equalTo(emailCodeTextField.snp.leading).offset(5)
        }
        
        nickNameTextField.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.067)
        }
        
        nickNameErrorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextField.snp.bottom).offset(1)
            make.leading.equalTo(nickNameTextField.snp.leading).offset(5)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextField.snp.bottom).offset(28)
            make.leading.equalTo(nickNameTextField.snp.leading).offset(5)
        }
        
        manButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(5)
            make.leading.equalTo(nickNameTextField.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.432)
            make.height.equalToSuperview().multipliedBy(0.062)
        }
        
        womanButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(5)
            make.trailing.equalTo(nickNameTextField.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.432)
            make.height.equalToSuperview().multipliedBy(0.062)
        }

        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(manButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalToSuperview().multipliedBy(0.062)
            make.bottom.equalToSuperview()
        }
    }
}
*/
