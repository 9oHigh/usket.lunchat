//
//  NotificationTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    static let identifier = "NotificationTableViewCell"
    private let eventImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = nil
        titleLabel.text = nil
        subLabel.text = nil
        timeLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventImageView.layoutIfNeeded()
        eventImageView.layer.cornerRadius = eventImageView.bounds.width / 2
    }
    
    func setDataSource(data: Notification) {
        self.eventImageView.loadImageFromUrl(url: URL(string: "\(data.recipient.profilePicture)"))
        self.titleLabel.text = data.title
        self.subLabel.text = data.content
        self.timeLabel.text = data.createdAt.daysAgo
    }
    
    private func setConfig() {
        selectionStyle = .none
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 14)
        titleLabel.textColor = AppColor.black.color
        
        subLabel.textColor = AppColor.grayText.color
        subLabel.font = AppFont.shared.getRegularFont(size: 10)
        subLabel.numberOfLines = 2
        
        timeLabel.font = AppFont.shared.getBoldFont(size: 12)
        timeLabel.textColor = AppColor.grayText.color
    }
    
    private func setUI() {
        contentView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subLabel)
        contentView.addSubview(timeLabel)
    }
    
    private func setConstraint() {
        eventImageView.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.13)
            make.height.equalTo(eventImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.top)
            make.leading.equalTo(eventImageView.snp.trailing).offset(16)
        }
        
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(eventImageView.snp.trailing).offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.top)
            make.trailing.equalTo(-12)
        }
    }
}
