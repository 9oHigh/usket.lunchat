//
//  ProfileItemView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/23.
//

import UIKit

final class ProfileItemView: UIView {
    
    private let itemImageView = UIImageView()
    private let itemLabel = UILabel()
    private let pushImageView = UIImageView(image: UIImage(named: "push"))
    
    init(itemName: String, itemTitle: String) {
        super.init(frame: .zero)
        setConfig(itemName: itemName, itemTitle: itemTitle)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig(itemName: String, itemTitle: String) {
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.image = UIImage(named: itemName)

        itemLabel.text = itemTitle
        itemLabel.font = AppFont.shared.getBoldFont(size: 18)
        
        pushImageView.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        addSubview(itemImageView)
        addSubview(itemLabel)
        addSubview(pushImageView)
    }
    
    private func setConstraint() {
        itemImageView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        itemLabel.snp.makeConstraints { make in
            make.centerY.equalTo(itemImageView.snp.centerY)
            make.leading.equalTo(itemImageView.snp.trailing).offset(12)
            make.width.equalTo(150)
        }
        
        pushImageView.snp.makeConstraints { make in
            make.centerY.equalTo(itemImageView.snp.centerY)
            make.trailing.equalTo(-16)
        }
    }
}
