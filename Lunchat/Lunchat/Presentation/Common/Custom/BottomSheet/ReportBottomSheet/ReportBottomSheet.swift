//
//  ReportBottomSheet.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/04.
//

import UIKit
import RxSwift

final class ReportBottomSheet: BaseViewController {
    
    private let targetUser: String
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let textView = LunchatTextView()
    private let reportButton = LunchatButton()
    private let cancelButton = LunchatButton()
    
    init(targetUser: String) {
        self.targetUser = targetUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
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
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyborad))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = AppColor.black.color.withAlphaComponent(0.45)
        
        contentView.backgroundColor = .white
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 24)
        titleLabel.textColor = AppColor.purple.color
        titleLabel.text = "신고하기"
        
        subTitleLabel.font = AppFont.shared.getRegularFont(size: 14)
        subTitleLabel.textColor = AppColor.grayText.color
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .left
        subTitleLabel.lineBreakMode = .byCharWrapping
        subTitleLabel.text = "지식재산권 침해를 신고하는 경우를 제외하고 회원님의 신고는 익명으로 처리됩니다. 누군가 위급한 상황에 있다고 생각된다면 즉시 현지 응급 서비스 기관에 연락하시기 바랍니다."
        
        textView.textAlignment = .left
        textView.setPlaceholer("신고 내용을 작성해 주세요")
        
        reportButton.setFont(of: 16)
        reportButton.setTitle("신고접수", for: .normal)
        cancelButton.setFont(of: 16)
        cancelButton.setTitle("취소", for: .normal)
    }
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(reportButton)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            contentView.frame.origin.y = keyWindow.bounds.size.height
        }
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.5).offset(bottomInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(20)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(30)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(reportButton.snp.top).offset(-20)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.height).multipliedBy(0.1)
            make.width.equalToSuperview().multipliedBy(0.453)
            make.centerX.equalToSuperview().multipliedBy(0.525)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
        
        reportButton.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.height).multipliedBy(0.1)
            make.width.equalToSuperview().multipliedBy(0.453)
            make.centerX.equalToSuperview().multipliedBy(1.475)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    @objc
    private func hideKeyborad(_ sender: UIGestureRecognizer) {
        if textView.isFirstResponder {
            self.view.endEditing(true)
        } else {
            if isTouchInContentViewOrSubViews(location: sender.location(in: self.view)) {
                return
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func isTouchInContentViewOrSubViews(location: CGPoint) -> Bool {
        
        if contentView.frame.contains(location) {
            return true
        }
        
        for subview in contentView.subviews {
            let subviewFrameInSuperview = subview.convert(subview.bounds, to: self.view)
            if subviewFrameInSuperview.contains(location) {
                return true
            }
        }
        
        return false
    }
    
    
    func isAvailableReportReason() -> Bool {
        if textView.text == textView.getPlaceholder() || textView.text.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func getReportButtonObservable() -> Observable<String> {
        return reportButton.rx.tap
            .withUnretained(self)
            .map { owner, _ in owner.textView.text }
            .asObservable()
    }
    
    func getCancelButtonObservable() -> Observable<Void> {
        return cancelButton.rx.tap.asObservable()
    }
}
