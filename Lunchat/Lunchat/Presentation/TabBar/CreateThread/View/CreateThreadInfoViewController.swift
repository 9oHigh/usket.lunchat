//
//  CreateThreadInfoViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import UIKit
import RxSwift
import RxGesture
import PhotosUI

final class CreateThreadInfoViewController: BaseViewController {
    
    private var imagePickerController: PHPickerViewController!
    private let restaurantTitleLabel = UILabel()
    private let restaurantTextField = LunchatTextField(maxLength: nil)
    
    private let contentTitleLabel = UILabel()
    private let contentTextView = LunchatTextView()
    
    private let photoLabel = UILabel()
    private let photoImageView = UIImageView()
    private let deleteButton = UIButton(type: .custom)
    
    private let successButton = LunchatButton()
    
    private let viewModel: CreateThreadViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: CreateThreadViewModel) {
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
        setBottomLine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    private func setConfig() {
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self
        
        restaurantTitleLabel.text = "식당 이름을 작성해주세요 (필수)"
        restaurantTitleLabel.font = AppFont.shared.getBoldFont(size: 15)
        restaurantTitleLabel.textColor = AppColor.black.color
        
        let attributedMessagePlaceholer = NSAttributedString(string: "식당 이름을 작성해주세요", attributes: [ NSAttributedString.Key.foregroundColor: AppColor.grayText.color, NSAttributedString.Key.font: AppFont.shared.getRegularFont(size: 15)])
        restaurantTextField.attributedPlaceholder = attributedMessagePlaceholer
        restaurantTextField.font = AppFont.shared.getBoldFont(size: 15)
        restaurantTextField.text = viewModel.getRestaurantTitle()
        restaurantTextField.setCheck()
        
        contentTitleLabel.text = "내용을 작성해주세요 (필수)"
        contentTitleLabel.font = AppFont.shared.getBoldFont(size: 15)
        contentTitleLabel.textColor = AppColor.black.color
        
        contentTextView.setPlaceholer("최소 10자 이상의 내용을 작성해주세요.")
        
        photoLabel.text = "사진을 업로드해주세요 (선택)"
        photoLabel.font = AppFont.shared.getBoldFont(size: 15)
        photoLabel.textColor = AppColor.black.color
        
        photoImageView.image = UIImage(named: "default_photo")
        photoImageView.contentMode = .scaleToFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 5
        
        deleteButton.setImage(UIImage(named: "delete_photo"), for: .normal)
        deleteButton.backgroundColor = .clear
        deleteButton.imageView?.contentMode = .scaleAspectFill
        
        successButton.setFont(of: 16)
        successButton.setTitle("완료", for: .normal)
        successButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(restaurantTitleLabel)
        view.addSubview(restaurantTextField)
        view.addSubview(contentTitleLabel)
        view.addSubview(contentTextView)
        view.addSubview(photoLabel)
        view.addSubview(photoImageView)
        view.addSubview(deleteButton)
        view.addSubview(successButton)
    }
    
    private func setConstraint() {
        restaurantTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.leading.equalTo(16)
            make.height.equalTo(restaurantTitleLabel.font.pointSize + 4)
        }
        
        restaurantTextField.snp.makeConstraints { make in
            make.top.equalTo(restaurantTitleLabel.snp.bottom).offset(20)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(24)
        }
        
        contentTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(restaurantTextField.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(contentTitleLabel.font.pointSize + 4)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.28)
        }
        
        photoLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(photoLabel.font.pointSize + 4)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(photoLabel.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.width.equalTo(70)
            make.height.equalTo(90)
        }
        
        deleteButton.isHidden = true
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.top).offset(4)
            make.trailing.equalTo(photoImageView.snp.trailing).offset(-4)
            make.width.height.equalTo(24)
        }
        
        successButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        viewModel.subscribeFileUrl()
        viewModel.subscribeIsCreated { [weak self] in
            self?.hideLoadingView()
        }
        
        restaurantTextField.rx.controlEvent([.editingChanged, .editingDidEnd])
            .map { [weak self] in self?.restaurantTextField.text }
            .subscribe({ [weak self] text in
                guard let self = self else { return }
                if let text = text.element, let isEmpty = text?.isEmpty, isEmpty {
                    self.restaurantTextField.setError()
                    self.successButton.setInActive()
                } else {
                    self.restaurantTextField.setCheck()
                    if self.contentTextView.getPlaceholder() != self.contentTextView.text && !self.contentTextView.text.isEmpty {
                        self.successButton.setActive()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe({ [weak self] text in
                guard let self = self else { return }
                if let text = text.element, text != self.contentTextView.getPlaceholder() && !text.isEmpty {
                    self.successButton.setActive()
                } else {
                    self.successButton.setInActive()
                }
        })
        .disposed(by: disposeBag)
        
        successButton.rx.tap
            .map { [weak self] in
                return (self?.restaurantTextField.text, self?.contentTextView.text)
            }
            .subscribe({ [weak self] parms in
                self?.showLoadingView()
                if let parms = parms.element, let title = parms.0, let content = parms.1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.viewModel.createThread(title: title, content: content)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        photoImageView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imagePickerController.modalPresentationStyle = .fullScreen
                self.present(self.imagePickerController, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        photoImageView.rxImage.subscribe({ [weak self] image in
            if let image = image.element {
                if image != UIImage(named: "default_photo") {
                    self?.addDeleteButton()
                } else {
                    self?.removeDeleteButton()
                }
            }
        })
        .disposed(by: disposeBag)
        
        deleteButton.rx.tap.subscribe({ [weak self] _ in
            self?.photoImageView.image = UIImage(named: "default_photo")
        })
        .disposed(by: disposeBag)
    }
}

extension CreateThreadInfoViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                
                guard let image = reading as? UIImage,
                      error == nil
                else { return }

                DispatchQueue.main.async {
                    AlertManager.shared.showRestaurantPhotoPicker(picker) { isSent in
                        if isSent {
                            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
                                guard let fileURL = url else { return }
                                let fileExtension = fileURL.pathExtension.lowercased()
                                let imageExtension = ImageExtension(rawValue: fileExtension)
                                if let type = imageExtension {
                                    self?.viewModel.postToImagePresignedUrl(image: image, imageType: type.rawValue)
                                    DispatchQueue.main.async {
                                        self?.photoImageView.image = image
                                        self?.addDeleteButton()
                                        picker.dismiss(animated: true)
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                picker.dismiss(animated: true)
                            }
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
    
    private func addDeleteButton() {
        self.deleteButton.isHidden = false
        self.deleteButton.isEnabled = true
    }
    
    private func removeDeleteButton() {
        self.deleteButton.isHidden = true
        self.deleteButton.isEnabled = false
    }
}
