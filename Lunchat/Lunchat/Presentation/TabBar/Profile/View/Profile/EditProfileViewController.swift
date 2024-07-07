//
//  EditProfileViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/18.
//

import UIKit
import RxSwift
import RxGesture
import PhotosUI

final class EditProfileViewController: BaseViewController {
    
    private var imagePickerController: PHPickerViewController!
    private let profileBackground = UIImageView(image: UIImage(named: "profileBackground"))
    private let profileEditImageView = UIImageView()
    private let cameraImageView = UIImageView(image: UIImage(named: "camera"))
    
    private let nicknameLabel = UILabel()
    private let nicknameTextField = LunchatTextField(maxLength: 10)
    private let nicknameAdviceLabel = UILabel()
    private let errorLabel = UILabel()
    
    private let genderLabel = UILabel()
    private let manButton = GenderButtonView()
    private let womanButton = GenderButtonView()
    private let genderLine = UIView()
    
    private let introduceLabel = UILabel()
    private let introduceTextField = LunchatTextField(maxLength: 10)
    
    private let saveButton = LunchatButton()
    
    private let viewModel: EditProfileViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: EditProfileViewModel){
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
        setBottomLine()
        showLoadingView()
        viewModel.getUserProfile()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileEditImageView.layoutIfNeeded()
        profileEditImageView.layer.cornerRadius = profileEditImageView.frame.size.width / 2
    }
    
    private func setConfig() {
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self
        
        profileBackground.contentMode = .scaleAspectFit
        profileEditImageView.contentMode = .scaleAspectFill
        profileEditImageView.clipsToBounds = true
        
        cameraImageView.isUserInteractionEnabled = false
        
        nicknameLabel.text = "닉네임을 입력해 주세요."
        nicknameLabel.textColor = AppColor.black.color
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 15)
        
        nicknameTextField.placeholder = "한글, 영문 및 숫자 10자리 이내 닉네임"
        nicknameTextField.text = UserDefaults.standard.getUserInfo(.nickname) ?? ""
        nicknameTextField.setCheck()
        
        nicknameAdviceLabel.text = "불쾌감을 주는 별명 및 닉네임 입력 시 서비스 이용이 제한될 수 있습니다.\n닉네임은 14일 안에 한 번만 변경할 수 있습니다.\n닉네임은 4글자 이상 10글자 이하입니다."
        nicknameAdviceLabel.textColor = AppColor.grayText.color
        nicknameAdviceLabel.font = AppFont.shared.getRegularFont(size: 11)
        nicknameAdviceLabel.numberOfLines = 0
        nicknameAdviceLabel.lineBreakMode = .byCharWrapping
        
        errorLabel.font = AppFont.shared.getRegularFont(size: 11)
        errorLabel.textColor = AppColor.red.color
        errorLabel.text = "사용할 수 없는 닉네임입니다."
        errorLabel.isHidden = true
        
        genderLabel.text = "성별을 선택해 주세요."
        genderLabel.textColor = AppColor.black.color
        genderLabel.font = AppFont.shared.getBoldFont(size: 15)
        
        manButton.setTitle(title: "남자")
        womanButton.setTitle(title: "여자")
        
        UserDefaults.standard.getUserGender() ? manButton.setActive() : womanButton.setActive()
        
        genderLine.backgroundColor = AppColor.purple.color
        
        introduceLabel.text = "자기소개를 작성해주세요."
        introduceLabel.textColor = AppColor.black.color
        introduceLabel.font = AppFont.shared.getBoldFont(size: 15)
        
        introduceTextField.placeholder = "10글자 이내 짧은 자기소개"
        introduceTextField.text = UserDefaults.standard.getUserInfo(.bio) ?? ""
        introduceTextField.setCheck()
        
        saveButton.setFont(of: 16)
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setActive()
    }
    
    private func setUI() {
        view.addSubview(profileBackground)
        view.addSubview(profileEditImageView)
        view.addSubview(cameraImageView)
        
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameAdviceLabel)
        view.addSubview(errorLabel)
        
        view.addSubview(genderLabel)
        view.addSubview(manButton)
        view.addSubview(womanButton)
        view.addSubview(genderLine)
        
        view.addSubview(introduceLabel)
        view.addSubview(introduceTextField)
        
        view.addSubview(saveButton)
    }
    
    private func setConstraint() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        profileEditImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.301)
            make.height.equalTo(profileEditImageView.snp.width)
        }
        
        profileBackground.snp.makeConstraints { make in
            make.centerX.equalTo(profileEditImageView.snp.centerX)
            make.centerY.equalTo(profileEditImageView.snp.centerY)
            make.width.equalTo(profileEditImageView.snp.width).offset(12)
            make.height.equalTo(profileEditImageView.snp.height).offset(12)
        }
        
        cameraImageView.snp.makeConstraints { make in
            make.trailing.equalTo(profileEditImageView.snp.trailing)
            make.bottom.equalTo(profileEditImageView.snp.bottom)
            make.width.height.equalTo(profileBackground.snp.width).multipliedBy(0.21)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileEditImageView.snp.bottom).offset(30)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(20)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(24)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(12)
            make.leading.equalTo(nicknameTextField.snp.leading).offset(4)
        }
        
        nicknameAdviceLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(28)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameAdviceLabel.snp.bottom).offset(30)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        manButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(20)
            make.leading.equalTo(16)
            make.height.equalTo(32)
            make.width.equalToSuperview().multipliedBy(0.425)
        }
        
        womanButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(20)
            make.trailing.equalTo(-16)
            make.height.equalTo(32)
            make.width.equalToSuperview().multipliedBy(0.425)
        }
        
        genderLine.snp.makeConstraints { make in
            make.top.equalTo(manButton.snp.bottom).offset(4)
            make.height.equalTo(3)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.top.equalTo(manButton.snp.bottom).offset(30)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        introduceTextField.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(20)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.92)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    private func bind() {
        
        let localNickname = UserDefaults.standard.getUserInfo(.nickname) ?? ""
        let localBio = UserDefaults.standard.getUserInfo(.bio) ?? ""
        
        let mergedGenderSign = Observable<Bool>.merge(manButton.rx.tapGesture().asObservable().map { _ in true }, womanButton.rx.tapGesture().asObservable().map { _ in false }).asSignal(onErrorJustReturn: true)
        let introTextSign = introduceTextField.rx.text.orEmpty.asSignal(onErrorJustReturn: UserDefaults.standard.getUserInfo(.bio) ?? "")
        
        let input = EditProfileViewModel.Input(
            editPhotoSign: profileEditImageView.rx.tapGesture().map { _ in () }.asSignal(onErrorJustReturn: ()),
            gender: mergedGenderSign,
            introduceText: introTextSign,
            saveSign: saveButton.rx.tap
                .withUnretained(self)
                .map { owner, _ in
                return UpdateUserInformation(
                    profilePictrue: "",
                    nickname: owner.nicknameTextField.text ?? localNickname,
                    gender: owner.womanButton.getStatus(),
                    bio: owner.introduceTextField.text ?? localBio)
            }.asSignal(onErrorJustReturn: nil))
        
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
        
        output.profile
            .withUnretained(self)
            .compactMap({ owner, profile in
                owner.hideLoadingView(0)
                return profile == nil ? nil : profile
            })
            .subscribe({ [weak self] profile in
            
            guard let profile = profile.element,
                  let profileUrl = profile.profilePicture
            else { return }
            
            DispatchQueue.main.async {
                self?.profileEditImageView.loadImageFromUrl(url: URL(string: profileUrl), isDownSampling: false)
            }
            
            self?.nicknameTextField.text = profile.nickname
            
            if profile.gender {
                self?.manButton.setActive()
                self?.womanButton.setInActive()
            } else {
                self?.manButton.setInActive()
                self?.womanButton.setActive()
            }
            
            self?.introduceTextField.text = profile.bio
            self?.introduceTextField.setCheck()
        })
        .disposed(by: disposeBag)
        
        output.showImagePickerSign.subscribe({ [weak self] showImagePicker in
            guard let self = self else { return }
            if let action = showImagePicker.element, action {
                DispatchQueue.main.async {
                    self.imagePickerController.modalPresentationStyle = .fullScreen
                    self.present(self.imagePickerController, animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.checkAllOptions().subscribe({ [weak self] isEnabled in
            guard let isEnabled = isEnabled.element else { return }
            self?.saveButton.isEnabled = isEnabled
            isEnabled ? self?.saveButton.setActive() : self?.saveButton.setInActive()
        })
        .disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe({ [weak self] text in
                guard let self = self else { return }
                
                if nicknameTextField.isEditing {
                    self.errorLabel.isHidden = true
                    self.nicknameTextField.setNomal()
                    self.saveButton.setInActive()
                    self.saveButton.isEnabled = false
                }
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
    
    deinit {
        disposeBag = DisposeBag()
    }
}
extension EditProfileViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        results.forEach { [weak self] result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                
                guard let image = reading as? UIImage,
                      error == nil
                else { return }

                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
                    guard let fileURL = url else { return }
                    let fileExtension = fileURL.pathExtension.lowercased()
                    let imageExtension = ImageExtension(rawValue: fileExtension)
                    if let type = imageExtension {
                        self?.viewModel.postToImagePresignedUrl(image: image, imageType: type.rawValue)
                        DispatchQueue.main.async {
                            self?.profileEditImageView.image = image
                            self?.hideLoadingView(0.5)
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
        }
        
        if results.isEmpty {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
            return
        }
    }
}
