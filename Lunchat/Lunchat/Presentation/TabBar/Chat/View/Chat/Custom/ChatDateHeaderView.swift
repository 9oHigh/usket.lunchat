//
//  ChatDateHeaderView.swift
//  Lunchat
//
//  Created by 이경후 on 5/16/24.
//

import MessageKit
import UIKit

final class ChatDateHeaderView: MessageReusableView {
    
    private let dateLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with text: NSAttributedString) {
        setConfig(with: text)
        setUI()
        setConstraint()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.attributedText = nil
    }
    
    private func setConfig(with text: NSAttributedString) {
        dateLabel.backgroundColor = AppColor.chatDate.color
        dateLabel.attributedText = text
        dateLabel.textAlignment = .center
        dateLabel.layer.cornerRadius = 12
        dateLabel.layer.masksToBounds = true
    }
    
    private func setUI() {
        addSubview(dateLabel)
    }
    
    private func setConstraint() {
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
            make.width.equalTo(140)
            make.height.equalTo(28)
        }
    }
}
