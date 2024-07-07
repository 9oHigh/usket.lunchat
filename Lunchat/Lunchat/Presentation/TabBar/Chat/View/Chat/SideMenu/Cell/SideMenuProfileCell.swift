//
//  SideMenuProfileCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/07.
//

import UIKit

final class SideMenuProfileCell: UITableViewCell {
    
    static let identifier = "SideMenuProfileCell"
    private let markMeImageVIew = UIImageView(image: UIImage(named: "markMe"))
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let bioLabel = UILabel()
    private var profile: Participant?
    
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
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nicknameLabel.text = nil
        bioLabel.text = nil
        markMeImageVIew.isHidden = true
        profile = nil
    }
    
    func setDataSource(participant: Participant) {
        self.profileImageView.loadImageFromUrl(url: URL(string: participant.profilePicture))
        self.nicknameLabel.text = participant.nickname
        self.bioLabel.text = participant.bio
        
        if let nickname = UserDefaults.standard.getUserInfo(.nickname) {
            if nickname == participant.nickname {
                markMeImageVIew.isHidden = false
            }
        }
        
        self.profile = participant
    }
    
    func getUserNickname() -> String? {
        return profile?.nickname
    }
    
    private func setConfig() {
        selectionStyle = .none
        
        markMeImageVIew.contentMode = .scaleAspectFit

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 16)
        nicknameLabel.textColor = AppColor.black.color
        
        bioLabel.font = AppFont.shared.getBoldFont(size: 10)
        bioLabel.textColor = AppColor.bio.color
        
        markMeImageVIew.isHidden = true
    }
    
    private func setUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(markMeImageVIew)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(bioLabel)
    }
    
    private func setConstraint() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(profileImageView.snp.height)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.bottom.equalTo(bioLabel.snp.top)
        }
        
        markMeImageVIew.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel.snp.centerY)
            make.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().offset(-2)
        }
    }
}
