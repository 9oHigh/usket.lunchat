//
//  MemberCollectionViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/09.
//

import UIKit

final class MemberCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MemberCollectionViewCell"
    private lazy var background = UIImageView(image: UIImage(named: "memberBackground"))
    private let profileImageView = UIImageView()
    
    private lazy var leaderView = UIView()
    private lazy var leaderLabel = UILabel()
    
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private var isLeader: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isLeader = nil
        self.profileImageView.image = nil
        self.leaderLabel.text = nil
        self.bioLabel.text = nil
        self.background.removeFromSuperview()
        self.leaderView.removeFromSuperview()
    }
    
    func setIsLeader(isLeader: Bool) {
        self.isLeader = isLeader
        setConfig()
        setUI()
        setConstraint()
    }
    
    func setDataSource(memberInfo: Participant?) {
        if let info = memberInfo {
            self.profileImageView.loadImageFromUrl(url: URL(string: info.profilePicture))
            self.nameLabel.text = info.nickname
            self.bioLabel.text = info.bio
        } else {
            self.profileImageView.image = UIImage(named: "emptyMember")
            self.nameLabel.text = ""
            self.bioLabel.text = ""
        }
    }
    
    private func setConfig() {
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 5
        
        nameLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 15 : 12)
        nameLabel.textColor = AppColor.black.color
        nameLabel.textAlignment = .center
        
        bioLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 12 : 9)
        bioLabel.textColor = AppColor.grayText.color
        bioLabel.textAlignment = .center
        
        if isLeader! {
            background.contentMode = .scaleAspectFill
            background.layer.cornerRadius = 5
            background.layer.masksToBounds = true
            
            leaderView.backgroundColor = AppColor.black.color
            leaderView.clipsToBounds = true
            leaderView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            leaderView.layer.cornerRadius = 5
            
            leaderLabel.font = AppFont.shared.getBoldFont(size: 10)
            leaderLabel.textColor = AppColor.white.color
            leaderLabel.text = "밥약 리더"
            leaderLabel.backgroundColor = .clear
            leaderLabel.textAlignment = .center
        }
    }
    
    private func setUI() {
        if isLeader! {
            contentView.addSubview(background)
            background.addSubview(profileImageView)
            profileImageView.addSubview(leaderView)
            leaderView.addSubview(leaderLabel)
            contentView.addSubview(nameLabel)
            contentView.addSubview(bioLabel)
        } else {
            contentView.addSubview(profileImageView)
            contentView.addSubview(nameLabel)
            contentView.addSubview(bioLabel)
        }
    }
    
    private func setConstraint() {
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        if isLeader! {
            background.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.7)
            }
            
            profileImageView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(2)
                make.trailing.bottom.equalToSuperview().offset(-2)
            }
            
            leaderView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.21)
            }
            
            leaderLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(background.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(inset > 20 ? 15 : 13)
            }
            
            bioLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.height.equalTo(inset > 20 ? 12 : 10)
                make.leading.trailing.equalToSuperview()
            }
        } else {
            profileImageView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(2)
                make.trailing.equalToSuperview().offset(-2)
                make.height.equalToSuperview().multipliedBy(0.7).offset(-4)
            }
 
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(profileImageView.snp.bottom).offset(6)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(inset > 20 ? 15 : 13)
            }
            
            bioLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.height.equalTo(inset > 20 ? 12 : 10)
                make.leading.trailing.equalToSuperview()
            }
        }
    }
}
