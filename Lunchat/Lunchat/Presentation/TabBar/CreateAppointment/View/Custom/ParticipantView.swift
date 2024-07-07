//
//  ParticipantView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/05.
//

import UIKit

final class ParticipantView: UIView {
    
    private let type: ParticipantCountType
    private let checkImageView = UIImageView(image: UIImage(named: "unCheck"))
    private let countLabel = UILabel()
    
    init(participantCountType: ParticipantCountType) {
        self.type = participantCountType
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
        
        checkImageView.contentMode = .scaleAspectFit
        
        countLabel.text = type.title
        countLabel.textColor = AppColor.grayText.color
        countLabel.font = AppFont.shared.getRegularFont(size: 16)
    }
    
    private func setUI() {
        addSubview(checkImageView)
        addSubview(countLabel)
    }
    
    private func setConstraint() {
        checkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkImageView.snp.trailing).offset(8)
            make.centerY.equalTo(checkImageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
    
    func setActive() {
        checkImageView.image = UIImage(named: "check")
        countLabel.textColor = AppColor.purple.color
        countLabel.font = AppFont.shared.getBoldFont(size: 16)
    }
    
    func setInActive() {
        checkImageView.image = UIImage(named: "unCheck")
        countLabel.textColor = AppColor.grayText.color
        countLabel.font = AppFont.shared.getRegularFont(size: 16)
    }
    
    func getIsActive() -> Bool {
        return countLabel.textColor == AppColor.purple.color
    }
    
    func getType() -> ParticipantCountType {
        return self.type
    }
}
