//
//  NoMessageView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/21.
//

import UIKit

final class NoChatRoomView: UIView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private var type: NoChatRoomType
    
    init(type: NoChatRoomType) {
        self.type = type
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        backgroundColor = AppColor.white.color
        
        imageView.contentMode = .scaleAspectFill
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        titleLabel.textColor = AppColor.black.color
        titleLabel.textAlignment = .center
        
        subLabel.font = AppFont.shared.getRegularFont(size: 13)
        subLabel.textColor = AppColor.grayText.color
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0
        
        imageView.image = UIImage(named: type.imageName)
        titleLabel.text = type.title
        subLabel.text = type.subTitle
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subLabel)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.725)
            make.centerX.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(58)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
}
