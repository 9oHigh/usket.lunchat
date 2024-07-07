//
//  SearchUserTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/16.
//

import UIKit

final class SearchUserTableViewCell: UITableViewCell {
    
    static let identifier = "SearchUserTableViewCell"
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let bioLabel = UILabel()
    private var nickname: String?
    
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
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.bioLabel.text = nil
        self.nickname = nil
    }
    
    func setDataSource(info: SearchedUser) {
        profileImageView.loadImageFromUrl(url: URL(string: info.profilePicture))
        nicknameLabel.text = info.nickname
        nickname = info.nickname
        bioLabel.text = info.bio
    }
    
    func getNickname() -> String? {
        return nickname
    }
    
    private func setConfig() {
        
        selectionStyle = .none
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.masksToBounds = true
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 16)
        nicknameLabel.textColor = AppColor.black.color
        
        bioLabel.font = AppFont.shared.getRegularFont(size: 14)
        bioLabel.textColor = AppColor.grayText.color
    }
    
    private func setUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(bioLabel)
    }
    
    private func setConstraint() {
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(self.profileImageView.snp.height)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
}
