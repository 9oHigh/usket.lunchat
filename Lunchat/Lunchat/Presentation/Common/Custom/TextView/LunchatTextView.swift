//
//  LunchatTextView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/19.
//

import UIKit
import RxSwift

final class LunchatTextView: UITextView {
    
    private var placeholder: String = ""
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setDefaultConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDefaultConfig() {
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.borderColor = AppColor.textFieldBorder.color.cgColor
        layer.borderWidth = 1
        
        textContainerInset = UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)
        
        font = AppFont.shared.getRegularFont(size: 14)
        backgroundColor = AppColor.textField.color
        textColor = AppColor.black.color
    }
    
    func setPlaceholer(_ placeholder: String) {
        self.placeholder = placeholder
        text = self.placeholder
        textColor = AppColor.deepGrayText.color
        
        rx.didBeginEditing
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                if self.text == self.placeholder {
                    self.text = ""
                    self.textColor = AppColor.black.color
                }
            })
            .disposed(by: disposeBag)
        
        rx.didEndEditing
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                
                if self.text.isEmpty {
                    self.text = self.placeholder
                    self.textColor = AppColor.deepGrayText.color
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getTextObservable() -> Observable<String> {
        return rx.text.orEmpty.asObservable()
    }
    
    func getPlaceholder() -> String {
        return placeholder
    }
}

final class LunchatLimitTextView: UIView {
    
    private let textView = LunchatTextView()
    private let limitLabel = UILabel()
    private var maxLimit = 0
    private let disposeBag = DisposeBag()
    
    init(max: Int, placeholder: String) {
        super.init(frame: .zero)
        maxLimit = max
        setConfig()
        setPlaceholder(placeholder)
        setUI()
        setConstraint()
        bind()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private func setConfig() {
        limitLabel.font = AppFont.shared.getRegularFont(size: 14)
        limitLabel.textAlignment = .right
    }
    
    private func setUI() {
        addSubview(textView)
        addSubview(limitLabel)
    }
    
    private func setConstraint() {
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(limitLabel.snp.top).offset(-6)
        }
        
        limitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-3)
            make.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        
        textView.rx.text.orEmpty
            .subscribe({ [weak self] text in
                guard let self = self else { return }
                guard let text = text.element else { return }
                
                let string = "\(text.count) / \(self.maxLimit)"
                let mutableString = NSMutableAttributedString(string: string)
                
                if text.count > self.maxLimit {
                   let subString = text.prefix(self.maxLimit)
                    self.textView.text = String(subString)
                }
                
                if let slashRange = string.range(of: " / ") {
                    let blackRange = NSRange(location: 0, length: string.distance(from: string.startIndex, to: slashRange.lowerBound))
                    mutableString.addAttribute(.foregroundColor, value: UIColor.black, range: blackRange)

                    let grayRange = NSRange(slashRange.upperBound.utf16Offset(in: string)..<string.utf16.count)
                    mutableString.addAttribute(.foregroundColor, value: UIColor.gray, range: grayRange)

                    let nsSlashRange = NSRange(slashRange, in: string)
                    mutableString.addAttribute(.foregroundColor, value: UIColor.gray, range: nsSlashRange)
                }
                
                self.limitLabel.attributedText = mutableString
            })
            .disposed(by: disposeBag)
    }
    
    private func setPlaceholder(_ placeholder: String) {
        textView.setPlaceholer(placeholder)
    }
    
    func getTextObservable() -> Observable<String> {
        return textView.getTextObservable()
    }
    
    func isEditted() -> Bool {
        if textView.text == textView.getPlaceholder() || textView.text.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func setScrollable(_ option: Bool) {
        textView.isScrollEnabled = option
    }
}
