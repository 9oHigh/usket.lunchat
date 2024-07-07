//
//  SignUpViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class SignUpViewController: BaseViewController {
    
    private let introLabel = UILabel()
    
    private let nicknameLabel = UILabel()
    private let nicknameTextField = LunchatTextField(maxLength: 10)
    private let errorLabel = UILabel()
    
    private let genderLabel = UILabel()
    private let manButton = GenderButtonView()
    private let womanButton = GenderButtonView()
    private let genderLine = UIView()
    
    private let introduceLabel = UILabel()
    private let introduceTextField = LunchatTextField(maxLength: 10)
    
    private let startButton = LunchatButton()
    
    private let viewModel: SignUpViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SignUpViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setConfig() {
        introLabel.font = AppFont.shared.getBoldFont(size: 20)
        introLabel.text = "시작하기 전에 LunChat에서 사용하실\n닉네임과 성별을 선택해 주세요"
        introLabel.numberOfLines = 0
        introLabel.lineBreakMode = .byWordWrapping
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 15)
        nicknameLabel.text = "닉네임을 입력해 주세요."
        
        nicknameTextField.placeholder = "4자리 이상 10자리 이내(한글, 영문 및 숫자)"
        
        errorLabel.font = AppFont.shared.getRegularFont(size: 10)
        errorLabel.textColor = AppColor.red.color
        errorLabel.text = "사용할 수 없는 닉네임입니다."
        errorLabel.isHidden = true
        
        genderLabel.font = AppFont.shared.getBoldFont(size: 15)
        genderLabel.text = "성별을 선택해 주세요."
        
        genderLine.backgroundColor = AppColor.inActive.color
        
        introduceLabel.text = "짧은 자기소개를 작성해주세요."
        introduceLabel.font = AppFont.shared.getBoldFont(size: 15)
        
        introduceTextField.placeholder = "10글자 이내 짧은 자기소개"
        
        manButton.setTitle(title: "남자")
        womanButton.setTitle(title: "여자")
        
        startButton.setFont(of: 20)
        startButton.setTitle("다음", for: .normal)
        startButton.setInActive()
        startButton.isEnabled = false
    }
    
    private func setUI() {
        view.addSubview(introLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(errorLabel)
        
        view.addSubview(genderLabel)
        view.addSubview(manButton)
        view.addSubview(womanButton)
        view.addSubview(genderLine)
        
        view.addSubview(introduceLabel)
        view.addSubview(introduceTextField)
        
        view.addSubview(startButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(44)
            make.leading.equalTo(16)
            make.trailing.equalTo(-32)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(60)
            make.leading.equalTo(16)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(18)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(24)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(12)
            make.leading.equalTo(16)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(40)
            make.leading.equalTo(16)
        }
        
        manButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(18)
            make.leading.equalTo(16)
            make.height.equalTo(32)
            make.width.equalToSuperview().multipliedBy(0.425)
        }
        
        womanButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(18)
            make.trailing.equalTo(-16)
            make.height.equalTo(32)
            make.width.equalToSuperview().multipliedBy(0.425)
        }
        
        genderLine.snp.makeConstraints { make in
            make.top.equalTo(manButton.snp.bottom).offset(4)
            make.height.equalTo(3)
            make.leading.equalTo(nicknameTextField.snp.leading)
            make.trailing.equalTo(nicknameTextField.snp.trailing)
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.top.equalTo(genderLine.snp.bottom).offset(40)
            make.leading.equalTo(16)
        }
        
        introduceTextField.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(18)
            make.leading.equalTo(nicknameTextField.snp.leading)
            make.trailing.equalTo(nicknameTextField.snp.trailing)
            make.height.equalTo(24)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(inset > 20 ? view.safeAreaLayoutGuide.snp.bottomMargin : -12)
            make.leading.equalTo(nicknameTextField.snp.leading)
            make.trailing.equalTo(nicknameTextField.snp.trailing)
            make.height.equalTo(62)
        }
    }
    
    private func bind() {
        let mergedGenderSign = Observable<Bool>.merge(manButton.rx.tapGesture().asObservable().map { _ in true }, womanButton.rx.tapGesture().asObservable().map { _ in false }).asSignal(onErrorJustReturn: true)
        let introTextSign = introduceTextField.rx.text.orEmpty.asSignal(onErrorJustReturn: "")
        
        let input = SignUpViewModel.Input(
            gender: mergedGenderSign,
            introduceText: introTextSign,
            startSign: startButton.rx.tap.map {
                return SignupUserInfo(
                    nickname: self.nicknameTextField.text ?? "",
                    gender: self.womanButton.getStatus(),
                    bio: self.introduceTextField.text ?? "")
            }.asSignal(onErrorJustReturn: SignupUserInfo(nickname: "", gender: true, bio: "")))
        
        let output = viewModel.transform(input: input)
        
        output.isAvailableNickname
            .subscribe({ [weak self] available in
            if let available = available.element, available {
                self?.nicknameTextField.setCheck()
            } else {
                self?.nicknameTextField.setError()
                self?.errorLabel.isHidden = false
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.checkAllOptions().subscribe({ [weak self] isEnabled in
            guard let isEnabled = isEnabled.element else { return }
            self?.startButton.isEnabled = isEnabled
            isEnabled ? self?.startButton.setActive() : self?.startButton.setInActive()
        })
        .disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self else { return }

                if nicknameTextField.isEditing {
                    self.errorLabel.isHidden = true
                    self.nicknameTextField.setNomal()
                    self.startButton.setInActive()
                    self.startButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent(.editingDidBegin)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.errorLabel.isHidden = true
                self.nicknameTextField.setNomal()
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent([.editingDidEnd])
            .subscribe({ [weak self] _ in
                guard let self = self,
                      let text = self.nicknameTextField.text
                else { return }
                self.errorLabel.isHidden = true
                self.viewModel.checkAvailableNickname(nickname: text)
            })
            .disposed(by: disposeBag)
        
        introduceTextField.rx.text.orEmpty
            .debounce(.microseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let text = text.element, text != ""
                else {
                    self?.introduceTextField.setNomal()
                    return
                }
            })
            .disposed(by: disposeBag)
        
        introduceTextField.rx.controlEvent([.editingDidEnd, .editingDidBegin])
            .subscribe({ [weak self] _ in
                guard let self = self,
                      let text = introduceTextField.text
                else { return }
                
                if text.isEmpty {
                    self.introduceTextField.setNomal()
                } else {
                    self.introduceTextField.setCheck()
                }
            })
            .disposed(by: disposeBag)
        
        manButton.rx.tapGesture()
            .when(.recognized)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                
                self.genderLine.backgroundColor = AppColor.purple.color
                
                if self.manButton.getStatus() {
                    self.manButton.setActive()
                    self.womanButton.setInActive()
                }
            })
            .disposed(by: disposeBag)
        
        womanButton.rx.tapGesture()
            .when(.recognized)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                
                self.genderLine.backgroundColor = AppColor.purple.color
                
                if self.womanButton.getStatus() {
                    self.womanButton.setActive()
                    self.manButton.setInActive()
                }
            })
            .disposed(by: disposeBag)
    }
}
