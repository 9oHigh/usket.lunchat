//
//  ChatCreate.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/12.
//

import UIKit
import RxSwift

final class UseNoteTicket: DefaultBaseBottomSheet {
    
    private var loadingView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private let messageTextField = LunchatTextField(maxLength: 20)
    private var isShowingKeyboard: Bool = false
    private var disposBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(.question)
        setButtons(.divided)
        setConfig()
        setUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.setConstraints()
            self.contentView.frame.origin.y = self.contentView.frame.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func setConfig() {
        view.backgroundColor = AppColor.black.color.withAlphaComponent(0.45)
        
        messageTextField.placeholder = "안녕하세요 :)"
        titleLabel.font = AppFont.shared.getBoldFont(size: 20)
        loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = .clear
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setUI() {
        contentView.addSubview(messageTextField)
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(260 + bottomInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(22)
            make.width.equalToSuperview().multipliedBy(0.92)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.453)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.104)
            make.centerX.equalToSuperview().multipliedBy(0.525)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
        
        checkButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.453)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.104)
            make.centerX.equalToSuperview().multipliedBy(1.475)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    private func bind() {
        messageTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .subscribe({ [weak self] hasText in
                if let hasText = hasText.element, hasText {
                    self?.messageTextField.setCheck()
                } else {
                    self?.messageTextField.setNomal()
                }
            })
            .disposed(by: disposBag)
        
        view.rx.tapGesture(configuration: { gestureRecognizer, delegate in
            delegate.simultaneousRecognitionPolicy = .never
            gestureRecognizer.cancelsTouchesInView = false
        })
        .when(.recognized)
        .subscribe(onNext: { [weak self] gesture in
            guard let self = self else { return }
            
            let location = gesture.location(in: self.view)
            
            if self.isTouchInContentViewOrSubViews(location: location) {
                return
            } else {
                if self.messageTextField.isFirstResponder {
                    self.view.endEditing(true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        })
        .disposed(by: disposBag)
    }
    
    func setUserNickname(nickname: String) {
        self.titleLabel.text = "\(nickname)님께 쪽지를 보내시겠습니까?"
        self.detailLabel.text = "메시지를 입력해 주세요. 전송 시 쪽지가 소진됩니다."
    }
    
    func getCancelButtonObservable() -> Observable<Void> {
        return cancelButton.rx.tap.asObservable()
    }
    
    func getCheckButtonObservable() -> Observable<Void> {
        return checkButton.rx.tap.asObservable()
    }
    
    func getMessage() -> String? {
        if let message = self.messageTextField.text, !message.isEmpty {
            return message
        } else {
            return self.messageTextField.placeholder ?? "안녕하세요 :)"
        }
    }
    
    func showLoadingView() {
        view.addSubview(loadingView)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
    }
    
    func hideLoadingView(_ interval: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.loadingView.removeFromSuperview()
            UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        }
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let activeField = findActiveTextFieldOrTextView(in: self.view),
           let activeFrame = activeField.superview?.convert(activeField.frame, to: self.view),
           !isShowingKeyboard {
            
            let keyboardHeight = keyboardFrame.size.height
            
            let maxY = activeFrame.maxY
            let keyboardTop = self.view.frame.size.height - keyboardHeight
            
            if maxY > keyboardTop {
                let yOffset = maxY - keyboardTop + 120
                self.view.frame.origin.y -= yOffset
            }
            
            isShowingKeyboard = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        self.view.frame.origin.y = 0
        isShowingKeyboard = false
    }
    
    private func findActiveTextFieldOrTextView(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder && (subview is UITextField || subview is UITextView) {
                return subview
            }
            if let foundSubview = findActiveTextFieldOrTextView(in: subview) {
                return foundSubview
            }
        }
        return nil
    }
    
    private func isTouchInContentViewOrSubViews(location: CGPoint) -> Bool {
        if contentView.frame.contains(location) {
            return true
        }
        
        for subview in contentView.subviews {
            if subview.frame.contains(location) {
                return true
            }
        }
        
        return false
    }
    
    deinit {
        disposBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}
