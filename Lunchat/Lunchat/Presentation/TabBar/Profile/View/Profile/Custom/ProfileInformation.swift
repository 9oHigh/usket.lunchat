//
//  ProfileInformation.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/12.
//

import UIKit

final class ProfileInformationView: UIView {
    
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let bioLabel = UILabel()
    
    private let receivedImageView = UIImageView()
    private let receivedLabel = UILabel()
    
    private let successImageView = UIImageView()
    private let successLabel = UILabel()
    
    private let participationImageView = UIImageView()
    private let participationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    private func setConfig() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 6
        profileImageView.layer.borderColor = AppColor.purple.color.cgColor
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 24)
        nicknameLabel.textAlignment = .center
        
        bioLabel.font = AppFont.shared.getBoldFont(size: 18)
        bioLabel.textColor = AppColor.bio.color
        bioLabel.textAlignment = .center
        
        receivedImageView.image = UIImage(named: "recievedCount")
        receivedImageView.contentMode = .scaleAspectFit
        receivedLabel.font = AppFont.shared.getBoldFont(size: 18)
        
        successImageView.image = UIImage(named: "successCount")
        successImageView.contentMode = .scaleAspectFit
        successLabel.font = AppFont.shared.getBoldFont(size: 18)
        
        participationImageView.image = UIImage(named: "participationCount")
        participationImageView.contentMode = .scaleAspectFit
        participationLabel.font = AppFont.shared.getBoldFont(size: 18)
        
        receivedLabel.text = "쪽지 받은 횟수 0"
        successLabel.text = "밥약 성공 횟수 0"
        participationLabel.text = "밥약 참여 횟수 0"
    }
    
    private func setUI() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(bioLabel)
        
        addSubview(receivedImageView)
        addSubview(receivedLabel)
        
        addSubview(successImageView)
        addSubview(successLabel)
        
        addSubview(participationImageView)
        addSubview(participationLabel)
    }
    
    private func setConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.topMargin)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.325)
            make.width.equalTo(profileImageView.snp.height)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.height.equalTo(nicknameLabel.font.pointSize + 4)
            make.centerX.equalToSuperview()
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(16)
            make.height.equalTo(bioLabel.font.pointSize + 4)
            make.centerX.equalToSuperview()
        }
        
        receivedImageView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.width.height.equalTo(40)
        }
        
        receivedLabel.snp.makeConstraints { make in
            make.leading.equalTo(receivedImageView.snp.trailing).offset(12)
            make.centerY.equalTo(receivedImageView.snp.centerY)
        }
        
        successImageView.snp.makeConstraints { make in
            make.top.equalTo(receivedImageView.snp.bottom).offset(18)
            make.leading.equalTo(16)
            make.width.height.equalTo(40)
        }
        
        successLabel.snp.makeConstraints { make in
            make.leading.equalTo(successImageView.snp.trailing).offset(12)
            make.centerY.equalTo(successImageView.snp.centerY)
        }
        
        participationImageView.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom).offset(18)
            make.leading.equalTo(16)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        participationLabel.snp.makeConstraints { make in
            make.leading.equalTo(participationImageView.snp.trailing).offset(12)
            make.centerY.equalTo(participationImageView.snp.centerY)
            make.bottom.equalToSuperview()
        }
    }
    
    func setProfileInfo(profileInfo: Profile) {
        nicknameLabel.text = profileInfo.nickname
        bioLabel.text = profileInfo.bio
        receivedLabel.text = "쪽지 받은 횟수 \(profileInfo.receivedTicketsCount)"
        successLabel.text = "밥약 성공 횟수 \(profileInfo.appointmentCreationCount)"
        participationLabel.text = "밥약 참여 횟수 \(profileInfo.appointmentParticipationCount)"
        if let url = profileInfo.profilePicture {
            profileImageView.loadImageFromUrl(url: URL(string: url), isDownSampling: false)
        }
    }
}
