//
//  SignInViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/01.
//
/*
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

final class SignInViewController: BaseViewController {
    
    private let logoImageView = UIImageView()
    private let emailTextField = SignInEmailTextField()
    private let passwordTextField = SignInPasswordTextField()
    private let signInButton = LunchatButton()
    
    private let findPasswordLabel = UILabel()
    private let findPasswordButton = UIButton()
    private let signUpLabel = UILabel()
    private let signUpButton = UIButton()
    
    private let leftLine = UIImageView(image: UIImage(named: "line"))
    private let loginLineLabel = UILabel()
    private let rightLine = UIImageView(image: UIImage(named: "line"))
    
    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    private let googleLoginButton: GIDSignInButton = GIDSignInButton()
    private let kakaoLoginButton = KakaoSignInButton()
    
    private let viewModel: SignInViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setConfig() {
        
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        
        signInButton.setTitle("로그인", for: .normal)
        signInButton.setFont(of: 18)
        
        findPasswordLabel.font = AppFont.shared.getBoldFont(size: 14)
        findPasswordLabel.textColor = AppColor.grayText.color
        findPasswordLabel.text = "비밀번호를 잊으셨나요?"

        findPasswordButton.setTitle("비밀번호 찾기", for: .normal)
        findPasswordButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 14)
        findPasswordButton.setTitleColor(AppColor.purple.color, for: .normal)
        findPasswordButton.backgroundColor = AppColor.white.color
            
        signUpLabel.font = AppFont.shared.getBoldFont(size: 14)
        signUpLabel.textColor = AppColor.grayText.color
        signUpLabel.text = "아직 계정이 없으신가요?"

        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 14)
        signUpButton.setTitleColor(AppColor.purple.color, for: .normal)
        signUpButton.backgroundColor = .white

        loginLineLabel.font = AppFont.shared.getBoldFont(size: 13)
        loginLineLabel.textColor = AppColor.grayText.color
        loginLineLabel.text = "LOG IN"
        
        appleLoginButton.addTarget(self, action: #selector(signInApple), for: .touchUpInside)
    }
    
    private func setUI() {
        view.addSubview(logoImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        
        view.addSubview(findPasswordLabel)
        view.addSubview(findPasswordButton)
        view.addSubview(signUpLabel)
        view.addSubview(signUpButton)
        
        view.addSubview(loginLineLabel)
        view.addSubview(leftLine)
        view.addSubview(rightLine)
        
        view.addSubview(appleLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(kakaoLoginButton)
    }
    
    private func setConstraint() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(4)
            make.trailing.equalTo(-4)
            make.height.equalToSuperview().multipliedBy(0.21)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(19)
            make.width.equalToSuperview().multipliedBy(0.925)
            make.height.equalTo(39)
            make.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(6)
            make.width.equalToSuperview().multipliedBy(0.925)
            make.height.equalTo(39)
            make.centerX.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(21)
            make.height.equalTo(39)
            make.width.equalTo(passwordTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        findPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(29)
            make.centerX.equalToSuperview().multipliedBy(0.75)
        }
        
        findPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(29)
            make.leading.equalTo(findPasswordLabel.snp.trailing).offset(5.25)
            make.height.equalTo(14)
        }
        
        signUpLabel.snp.makeConstraints { make in
            make.top.equalTo(findPasswordLabel.snp.bottom).offset(10)
            make.leading.equalTo(findPasswordLabel.snp.leading).offset(13)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(findPasswordButton.snp.bottom).offset(10)
            make.leading.equalTo(signUpLabel.snp.trailing).offset(5.25)
            make.height.equalTo(14)
        }
        
        loginLineLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        
        leftLine.snp.makeConstraints { make in
            make.trailing.equalTo(loginLineLabel.snp.leading).offset(-5)
            make.centerY.equalTo(loginLineLabel.snp.centerY)
            make.leading.equalTo(signInButton.snp.leading).offset(5)
        }
        
        rightLine.snp.makeConstraints { make in
            make.leading.equalTo(loginLineLabel.snp.trailing).offset(5)
            make.centerY.equalTo(loginLineLabel.snp.centerY)
            make.trailing.equalTo(signInButton.snp.trailing).offset(-5)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(loginLineLabel.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(44)
        }
        
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(6.35)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(44)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(googleLoginButton.snp.bottom).offset(6.35)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        
        let loginSign = signInButton.rx.tap.map {
            [self.emailTextField.text ?? "", self.passwordTextField.text ?? ""]
        }.asSignal(onErrorJustReturn: ["", ""])
        
        let input = SignInViewModel.Input(
            loginSign: loginSign,
            kakaoLoginSign: kakaoLoginButton.rx.tap.asSignal(),
            signUpSign: signUpButton.rx.tap.asSignal())
        let output = viewModel.transform(input: input)
        
        output.showToast
            .emit(onNext: { [weak self] message in
                self?.view.showToast(message)
            })
            .disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe({ [weak self] _ in
                self?.emailTextField.resignFirstResponder()
                self?.passwordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe({ [weak self] _ in
                self?.passwordTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
  
        googleLoginButton.addTarget(self, action: #selector(signInGoogle), for: .touchUpInside)
    }
    
    @objc
    private func signInGoogle() {
        viewModel.loginWithGoogle(self)
    }
    
    @objc
    private func signInApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let identityToken = appleIDCredential.identityToken,
               let accessToken = String(data: identityToken, encoding: .utf8) {
                viewModel.loginWithApple(accessToken: accessToken)
            }
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.view.showToast(MessageType.failAppleLogin.description)
    }
}
*/
