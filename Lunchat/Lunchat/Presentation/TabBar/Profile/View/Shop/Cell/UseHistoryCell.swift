//
//  UseHistoryCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/06.
//

import UIKit

final class UseHistoryCell: UITableViewCell {
    
    static let identifier = "UseHistoryCell"
    
    private let dateLabel = UILabel()
    private let toUserNameLabel = UILabel()
    private let anotherUserImageView = UIImageView()
    private let anotherUserNicknameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        anotherUserImageView.layoutIfNeeded()
        anotherUserImageView.layer.cornerRadius = anotherUserImageView.frame.size.width / 2
    }
    
    func setDataSource(date: String, toUserNickname: String, toUserProfileURL: String) {
        dateLabel.text = date.toPhotoTime
        
        if let url = URL(string: toUserProfileURL) {
            self.anotherUserImageView.loadImageFromUrl(url: url)
        } else {
            self.anotherUserImageView.image = UIImage(systemName: "circle.person")
        }
        
        anotherUserNicknameLabel.text = toUserNickname
        
        let nicknameText = "\(toUserNickname)님에게 쪽지를 보냈습니다."
        let nicknameAttributedString = NSMutableAttributedString(string: nicknameText)
        let nicknameRange = (nicknameText as NSString).range(of: "\(toUserNickname)")
        nicknameAttributedString.addAttribute(.foregroundColor, value: AppColor.purple.color, range: nicknameRange)
        toUserNameLabel.attributedText = nicknameAttributedString
    }
    
    private func setConfig() {
        
        selectionStyle = .none
        
        dateLabel.font = AppFont.shared.getBoldFont(size: 10)
        dateLabel.textColor = AppColor.thinGrayText.color
        
        toUserNameLabel.font = AppFont.shared.getBoldFont(size: 13)
        toUserNameLabel.textColor = AppColor.black.color
        
        anotherUserNicknameLabel.font = AppFont.shared.getBoldFont(size: 10)
        anotherUserNicknameLabel.textColor = AppColor.black.color
        
        anotherUserImageView.clipsToBounds = true
        anotherUserImageView.contentMode = .scaleAspectFill
    }
    
    private func setUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(toUserNameLabel)
        contentView.addSubview(anotherUserImageView)
        contentView.addSubview(anotherUserNicknameLabel)
    }
    
    private func setConstraint() {
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.leading.equalTo(12)
        }
        
        toUserNameLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalTo(12)
            make.bottom.equalTo(-12)
        }
        
        anotherUserImageView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        anotherUserNicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(anotherUserImageView.snp.bottom).offset(8)
            make.centerX.equalTo(anotherUserImageView.snp.centerX)
            make.bottom.equalTo(-12)
        }
    }
}
