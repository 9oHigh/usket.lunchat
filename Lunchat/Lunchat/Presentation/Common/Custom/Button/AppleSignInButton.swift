//
//  AppleSignInButton.swift
//  Lunchat
//
//  Created by 이경후 on 4/19/24.
//

import UIKit

final class AppleSignInButton: UIButton {
    
    private let appleImageView = UIImageView(image: UIImage(named: "apple"))
    private let backView = UIView()
    private let appleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        backView.backgroundColor = AppColor.black.color
        appleLabel.textColor = AppColor.white.color
        appleLabel.font = AppFont.shared.getRegularFont(size: 15)
        appleLabel.text = "Apple로 계속하기"
    }
    
    private func setUI() {
        addSubview(appleImageView)
        appleImageView.addSubview(backView)
        backView.addSubview(appleLabel)
    }
    
    private func setConstraint() {
        appleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        appleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(1.05)
            make.height.equalToSuperview()
        }
    }
}
