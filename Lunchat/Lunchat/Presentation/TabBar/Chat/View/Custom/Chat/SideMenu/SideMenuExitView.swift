//
//  ExitView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/07.
//

import UIKit

final class SideMenuExitView: UIView {
    
    private let exitImageView = UIImageView(image: UIImage(named: "exitRoom"))
    private let titleLabel = UILabel()
    
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
        backgroundColor = AppColor.textViewBorder.color
        exitImageView.contentMode = .scaleAspectFit
        titleLabel.text = "눈물을 머금고 채팅방 나가기"
        titleLabel.textColor = AppColor.deepGrayText.color
        titleLabel.font = AppFont.shared.getRegularFont(size: 14.5)
    }
    
    private func setUI() {
        addSubview(exitImageView)
        addSubview(titleLabel)
    }
    
    private func setConstraint() {
        exitImageView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.width.height.equalTo(16)
            make.leading.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(exitImageView.snp.centerY)
            make.leading.equalTo(exitImageView.snp.trailing).offset(4)
        }
    }
}
