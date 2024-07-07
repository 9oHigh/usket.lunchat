//
//  LunchatButton.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/19.
//

import UIKit

final class LunchatButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = AppColor.purple.color
            } else {
                backgroundColor = AppColor.inActive.color
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaultConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDefaultConfig() {
        setTitleColor(AppColor.white.color, for: .normal)
        backgroundColor = AppColor.purple.color
        clipsToBounds = true
        layer.cornerRadius = 5
    }

    func setActive() {
        backgroundColor = AppColor.purple.color
    }
    
    func setInActive() {
        backgroundColor = AppColor.inActive.color
    }
    
    func setFont(of size: CGFloat) {
        titleLabel?.font = AppFont.shared.getBoldFont(size: size)
    }
}
