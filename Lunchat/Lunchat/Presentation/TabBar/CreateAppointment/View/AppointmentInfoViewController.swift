//
//  AppointmentInfoViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import RxSwift

final class AppointmentInfoViewController: BaseViewController {
    
    private let messageImageView = UIImageView(image: UIImage(named: "message"))
    private let messageLabel = UILabel()
    private let messageTextField = UITextField()
    private let messageBottomLine = UIView()
    
    private let hashtagImageView = UIImageView(image: UIImage(named: "hashtag"))
    private let hashtagLabel = UILabel()
    private let hashtagTextField = UITextField()
    private let hashtagBottomLine = UIView()
    
    private let createButton = LunchatButton()
    
    private let viewModel: CreateAppointmentViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: CreateAppointmentViewModel) {
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
        view.endEditing(true)
    }
    
    private func setConfig() {
        messageImageView.contentMode = .scaleAspectFit
        
        messageLabel.text = "참가자들에게 전할 말을 적어주세요"
        messageLabel.font = AppFont.shared.getBoldFont(size: 18)
        messageLabel.textColor = AppColor.black.color
        
        let messageClearButton = UIButton()
        messageClearButton.setImage(UIImage(named: "clear"), for: .normal)
        messageClearButton.contentMode = .scaleAspectFit
        
        let attributedMessagePlaceholer = NSAttributedString(string: "내용을 입력해주세요(필수, 4글자 ~ 10글자)", attributes: [ NSAttributedString.Key.foregroundColor: AppColor.grayText.color, NSAttributedString.Key.font: AppFont.shared.getRegularFont(size: 16)])
        messageTextField.attributedPlaceholder = attributedMessagePlaceholer
        messageTextField.rightView = messageClearButton
        messageTextField.rightViewMode = .whileEditing
        messageTextField.textColor = AppColor.black.color
        messageTextField.font = AppFont.shared.getBoldFont(size: 16)
        
        messageBottomLine.backgroundColor = AppColor.grayText.color
        
        hashtagImageView.contentMode = .scaleAspectFit
        
        hashtagLabel.text = "해시태그를 작성해 주세요"
        hashtagLabel.font = AppFont.shared.getBoldFont(size: 18)
        hashtagLabel.textColor = AppColor.black.color
        
        let hashtagClearButton = UIButton()
        hashtagClearButton.setImage(UIImage(named: "clear"), for: .normal)
        hashtagClearButton.contentMode = .scaleAspectFit
        
        let attributedHashtagPlaceholer = NSAttributedString(string: "해시태그를 입력해주세요(선택) e.g) #점심 #강남", attributes: [ NSAttributedString.Key.foregroundColor: AppColor.grayText.color, NSAttributedString.Key.font: AppFont.shared.getRegularFont(size: 16)])
        hashtagTextField.attributedPlaceholder = attributedHashtagPlaceholer
        hashtagTextField.rightView = hashtagClearButton
        hashtagTextField.rightViewMode = .whileEditing
        hashtagTextField.textColor = AppColor.black.color
        hashtagTextField.font = AppFont.shared.getBoldFont(size: 16)
        
        hashtagBottomLine.backgroundColor = AppColor.grayText.color
        
        createButton.setFont(of: 16)
        createButton.setInActive()
        createButton.setTitle("밥약 생성", for: .normal)
    }
    
    private func setUI() {
        view.addSubview(messageImageView)
        view.addSubview(messageLabel)
        view.addSubview(messageTextField)
        view.addSubview(messageBottomLine)
        
        view.addSubview(hashtagImageView)
        view.addSubview(hashtagLabel)
        view.addSubview(hashtagTextField)
        view.addSubview(hashtagBottomLine)
        
        view.addSubview(createButton)
    }
    
    private func setConstraint() {
        messageImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.width.height.equalTo(16)
            make.leading.equalTo(16)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(messageImageView.snp.centerY)
            make.leading.equalTo(messageImageView.snp.trailing).offset(8)
            make.trailing.equalTo(-16)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(messageImageView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        messageBottomLine.snp.makeConstraints { make in
            make.top.equalTo(messageTextField.snp.bottom).offset(8)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(3)
        }
        
        hashtagImageView.snp.makeConstraints { make in
            make.top.equalTo(messageBottomLine).offset(24)
            make.width.height.equalTo(16)
            make.leading.equalTo(16)
        }
        
        hashtagLabel.snp.makeConstraints { make in
            make.centerY.equalTo(hashtagImageView.snp.centerY)
            make.leading.equalTo(hashtagImageView.snp.trailing).offset(8)
            make.trailing.equalTo(-16)
        }
        
        hashtagTextField.snp.makeConstraints { make in
            make.top.equalTo(hashtagImageView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        hashtagBottomLine.snp.makeConstraints { make in
            make.top.equalTo(hashtagTextField.snp.bottom).offset(8)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(3)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        createButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            if let title = self.messageTextField.text, let hashtags = self.hashtagTextField.text {
                self.viewModel.showCreateAppointment(title: title, hashtag: self.viewModel.extractHashtags(from: hashtags))
            }
        })
        .disposed(by: disposeBag)
        
        messageTextField.rx.text.orEmpty.subscribe({ [weak self] text in
            if let text = text.element, !text.isEmpty, text.count >= 4 && text.count <= 15 {
                self?.createButton.setActive()
                self?.createButton.isEnabled = true
                self?.messageBottomLine.backgroundColor = AppColor.purple.color
            } else {
                self?.createButton.setInActive()
                self?.createButton.isEnabled = false
                self?.messageBottomLine.backgroundColor = AppColor.grayText.color
            }
        })
        .disposed(by: disposeBag)
        
        hashtagTextField.rx.text.orEmpty.subscribe({ [weak self] text in
            if let text = text.element, !text.isEmpty,text.count >= 2 && text.count <= 15 && text.contains("#") && text.first == "#" {
                self?.hashtagBottomLine.backgroundColor = AppColor.purple.color
            } else {
                self?.hashtagBottomLine.backgroundColor = AppColor.grayText.color
            }
        })
        .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
