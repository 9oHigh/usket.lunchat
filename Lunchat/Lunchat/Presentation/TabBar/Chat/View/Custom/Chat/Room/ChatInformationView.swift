//
//  ChatInformationView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import UIKit

final class ChatInformationView: UIView {
    
    private let wrapperView = UIView()
    private let informationLabel = UILabel()
    private var type: ChatInformationType
    
    init(type: ChatInformationType) {
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
        
        wrapperView.backgroundColor = AppColor.black.color.withAlphaComponent(0.6)
        
        informationLabel.font = AppFont.shared.getBoldFont(size: 15)
        informationLabel.textColor = AppColor.white.color
        informationLabel.text = type.title
        
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 5
    }
    
    private func setUI() {
        addSubview(wrapperView)
        wrapperView.addSubview(informationLabel)
    }
    
    private func setConstraint() {
        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        informationLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
