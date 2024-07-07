//
//  SocialSignInVIewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/17.
//

import UIKit
import SnapKit
import RxSwift

final class SignInViewController: BaseViewController {
    
    private let logoImageView = UIImageView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setConfig() {
        logoImageView.image = UIImage(named: "Launch")
        logoImageView.contentMode = .scaleAspectFill
    }
    
    private func setUI() {
        view.addSubview(logoImageView)
        view.addSubview(kakaoLoginButton)
    }
    
    private func setConstraint() {
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(45.5)
            make.bottom.equalTo(-45.5)
        }
    }
    
    private func bind() {
        let input = SignInViewModel.Input(
            kakaoLoginSign: kakaoLoginButton.rx.tap.asSignal())
        let output = viewModel.transform(input: input)
    }
}
