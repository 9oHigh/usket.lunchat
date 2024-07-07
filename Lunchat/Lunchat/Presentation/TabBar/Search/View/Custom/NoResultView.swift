//
//  NoResultView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/15.
//

import UIKit

final class NoResultView: UIView {
    
    private let imageView = UIImageView(image: UIImage(named: "noResult"))
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    
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
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.text = "검색 결과가 없습니다"
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        titleLabel.textColor = AppColor.black.color
        titleLabel.textAlignment = .center
        
        subLabel.text = "다시 검색해주시기 바랍니다."
        subLabel.textColor = AppColor.grayText.color
        subLabel.font = AppFont.shared.getRegularFont(size: 13)
        subLabel.textAlignment = .center
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subLabel)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
            make.bottom.equalTo(titleLabel.snp.top).offset(-12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
}
