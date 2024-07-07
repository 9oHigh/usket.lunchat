//
//  WithdrawalOtherReasonCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/14.
//

import UIKit

final class WithdrawalOtherReasonView: UIView {
    
    private let introLabel = UILabel()
    private let subLabel = UILabel()
    private let textView = LunchatTextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        introLabel.textColor = AppColor.purple.color
        introLabel.font = AppFont.shared.getRegularFont(size: 14)
        introLabel.textAlignment = .left
        introLabel.text = "그 외 서비스에 개선되었으면 하는 내용을 자유롭게 적어주세요"
        introLabel.numberOfLines = 0
        introLabel.lineBreakMode = .byCharWrapping
        
        subLabel.textColor = AppColor.grayText.color
        subLabel.textAlignment = .left
        subLabel.font = AppFont.shared.getRegularFont(size: 12)
        subLabel.text = "자세하게 적어주시면 서비스 개선에 큰 도움이 됩니다."
        subLabel.numberOfLines = 0
        subLabel.lineBreakMode = .byCharWrapping
        
        textView.setPlaceholer("내용을 작성해 주세요")
    }
    
    private func setUI() {
        addSubview(introLabel)
        addSubview(subLabel)
        addSubview(textView)
    }
    
    private func setConstraints() {
        introLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(8)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(8)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalToSuperview()
        }
    }
    
    func getReasonText() -> String {
        return textView.text
    }
}
