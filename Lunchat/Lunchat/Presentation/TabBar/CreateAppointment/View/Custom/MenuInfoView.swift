//
//  MenuInfoView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit

final class MenuInfoView: UIView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let checkImageView = UIImageView(image: UIImage(named: "check"))
    private let bottomLine = UIView()
    private let menuType: MenuType
    
    init(menuType: MenuType) {
        self.menuType = menuType
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
        
        imageView.image = UIImage(named: menuType.rawValue)
        imageView.contentMode = .scaleAspectFit
        
        checkImageView.contentMode = .scaleAspectFill
        checkImageView.isHidden = true
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        titleLabel.textColor = AppColor.black.color
        titleLabel.numberOfLines = 1
        titleLabel.text = menuType.title
        
        subLabel.font = AppFont.shared.getRegularFont(size: 12)
        subLabel.textColor = AppColor.grayText.color
        subLabel.numberOfLines = 1
        subLabel.text = menuType.subTitle
        
        bottomLine.backgroundColor = AppColor.textFieldBorder.color
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subLabel)
        addSubview(checkImageView)
        addSubview(bottomLine)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
        }
        
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.bottom.equalTo(imageView.snp.bottom)
            make.trailing.equalTo(checkImageView.snp.leading).offset(20)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(subLabel.snp.centerY)
            make.width.height.equalTo(20)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    func setChecked() {
        self.checkImageView.isHidden = false
        self.bottomLine.backgroundColor = AppColor.purple.color
    }
    
    func setUnChecked() {
        self.checkImageView.isHidden = true
        self.bottomLine.backgroundColor = AppColor.textFieldBorder.color
    }
    
    func getIsHidden() -> Bool {
        return self.checkImageView.isHidden
    }
    
    func getMenuType() -> MenuType {
        return self.menuType
    }
}
