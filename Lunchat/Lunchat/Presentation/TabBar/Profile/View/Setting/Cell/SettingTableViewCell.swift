//
//  SettingTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/13.
//

import UIKit

final class SettingTableViewCell: UITableViewCell {
    
    static let identifier = "SettingTableViewCell"
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let pushButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConfig() {
        selectionStyle = .none
        
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 15)
        titleLabel.textColor = AppColor.black.color
        
        pushButton.setImage(UIImage(named: "push"), for: .normal)
        pushButton.tintColor = AppColor.black.color
        pushButton.backgroundColor = .clear
    }
    
    private func setUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(pushButton)
    }
    
    private func setConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.leading.equalTo(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        pushButton.snp.makeConstraints { make in
            make.trailing.equalTo(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    func setDataSource(_ settingType: SettingCellType) {
        switch settingType {
        case .feedback(let feedbackType):
            self.iconImageView.image = UIImage(named: feedbackType.rawValue)
            self.titleLabel.text = feedbackType.title
        case .notification(let notificationType):
            self.iconImageView.image = UIImage(named: notificationType.rawValue)
            self.titleLabel.text = notificationType.title
        case .support(let supprotType):
            self.iconImageView.image = UIImage(named: supprotType.rawValue)
            self.titleLabel.text = supprotType.title
        case .userStatus(let userStatusType):
            self.iconImageView.image = UIImage(named: userStatusType.rawValue)
            self.pushButton.isHidden = true
            self.titleLabel.text = userStatusType.title
        case .version(let versionType):
            self.iconImageView.image = UIImage(named: versionType.rawValue)
            self.pushButton.isHidden = true
            self.titleLabel.text = versionType.title
        }
    }
}
