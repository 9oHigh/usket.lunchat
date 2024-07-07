//
//  NicknameTextField.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/28.
//

import UIKit
import RxSwift

final class LunchatTextField: UITextField {
    
    private let clearButton = UIButton(type: .custom)
    private let checkImageView = UIImageView(image: UIImage(named: "check"))
    private let errorImageView = UIImageView(image: UIImage(named: "error"))
    private let bottomLineView = UIView()
    private var maxLength: Int?

    private let disposeBag = DisposeBag()
    
    init(maxLength: Int?) {
        if let maxLength = maxLength {
            self.maxLength = maxLength
        } else {
            self.maxLength = nil
        }
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraints()
        bind()
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 32, y: 0, width: 32, height: bounds.height )
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        autocorrectionType = .no
        autocapitalizationType = .none
        
        font = AppFont.shared.getBoldFont(size: 16)
        textColor = AppColor.black.color
        borderStyle = .none
        
        bottomLineView.backgroundColor = AppColor.inActive.color
        
        clearButton.setImage(UIImage(named: "clear"), for: .normal)
        clearButton.contentMode = .scaleAspectFit
        clearButton.imageView?.contentMode = .scaleAspectFit
        
        checkImageView.isHidden = true
        checkImageView.contentMode = .scaleAspectFit
        
        errorImageView.isHidden = true
        errorImageView.contentMode = .scaleAspectFit
        
        rightView = clearButton
        rightViewMode = .whileEditing
    }
    
    private func setUI() {
        subviews.first?.addSubview(clearButton)
        addSubview(checkImageView)
        addSubview(errorImageView)
        addSubview(bottomLineView)
    }
    
    private func setConstraints() {
        errorImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        bottomLineView.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.width.equalToSuperview()
            make.bottom.equalTo(10)
        }
    }
    
    private func bind() {
        rx.controlEvent(.editingDidBegin)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.bottomLineView.backgroundColor = AppColor.purple.color
                self.errorImageView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        rx.controlEvent(.editingChanged)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.bottomLineView.backgroundColor = AppColor.purple.color
                self.errorImageView.isHidden = true
                
                if let maxLength = maxLength {
                    if let text = self.text, text.count > maxLength {
                        let subString = text.prefix(maxLength)
                        self.text = String(subString)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        rx.controlEvent(.editingDidEnd)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.bottomLineView.backgroundColor = AppColor.inActive.color
                self.errorImageView.isHidden = true
            })
            .disposed(by: disposeBag)
  
        clearButton.rx.tap
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    func setError() {
        self.errorImageView.isHidden = false
        self.checkImageView.isHidden = true
        self.bottomLineView.backgroundColor = AppColor.red.color
        self.rightView = errorImageView
        self.rightViewMode = .always
    }
    
    func setNomal() {
        self.errorImageView.isHidden = true
        self.checkImageView.isHidden = true
        self.bottomLineView.backgroundColor = AppColor.inActive.color
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }
    
    func setCheck() {
        self.errorImageView.isHidden = true
        self.checkImageView.isHidden = false
        self.bottomLineView.backgroundColor = AppColor.purple.color
        self.rightView = checkImageView
        self.rightView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.rightViewMode = .always
    }
}
