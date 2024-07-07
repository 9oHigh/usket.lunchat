//
//  GenderButton.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/19.
//

import UIKit

enum GenderType: String {
    case man = "남자"
    case woman = "여자"
}

final class GenderButtonView: UIView {
    
    private let genderLabel = UILabel()
    private let checkImageView = UIImageView(image: UIImage(named: "check"))
    
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
        genderLabel.textColor = AppColor.inActive.color
        genderLabel.font = AppFont.shared.getBoldFont(size: 16)
        checkImageView.isHidden = true
        checkImageView.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        addSubview(genderLabel)
        addSubview(checkImageView)
    }
    
    private func setConstraint() {
        genderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func setTitle(title: String) {
        genderLabel.text = title
    }
    
    func getStatus() -> Bool {
        return checkImageView.isHidden
    }
    
    func setActive() {
        checkImageView.isHidden = false
        genderLabel.textColor = AppColor.black.color
        genderLabel.font = AppFont.shared.getBoldFont(size: 16)
    }
    
    func setInActive() {
        checkImageView.isHidden = true
        genderLabel.textColor = AppColor.inActive.color
        genderLabel.font = AppFont.shared.getRegularFont(size: 16)
    }
}
