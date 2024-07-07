//
//  PersnalChatCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/17.
//

import UIKit

final class PersonalChatCell: UITableViewCell {
    
    static let identifier = "PersonalChatCell"
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let lastChatLabel = UILabel()
    private var chatRoom: ChatRoom?
    
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
        self.chatRoom = nil
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.lastChatLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 20
    }
    
    func setDataSource(chatRoom: ChatRoom) {
        let nickname = UserDefaults.standard.getUserInfo(.nickname)
        let partner = chatRoom.participants.filter{ $0.nickname != nickname }.first
        
        profileImageView.loadImageFromUrl(url: URL(string: partner?.profilePicture ?? ""))
        nicknameLabel.text = partner?.nickname
        
        if let lastMessage = chatRoom.lastMessage?.content{
            lastChatLabel.text = lastMessage
        } else {
            lastChatLabel.text = "채팅을 시작해보세요!"
        }
        
        self.chatRoom = chatRoom
    }
    
    func getDataSource() -> ChatRoom? {
        if let chatRoom = self.chatRoom {
            return chatRoom
        }
        return nil
    }

    private func setConfig() {
        selectionStyle = .none
        
        profileImageView.contentMode = .scaleAspectFill
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 16)
        nicknameLabel.textColor = AppColor.black.color
        
        lastChatLabel.font = AppFont.shared.getRegularFont(size: 14)
        lastChatLabel.textColor = AppColor.thinGrayText.color
        lastChatLabel.numberOfLines = 2
    }
    
    private func setUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(lastChatLabel)
    }
    
    private func setConstraint() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.leading.equalTo(12)
            make.width.equalTo(profileImageView.snp.height)
            make.bottom.equalTo(-14)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.top.equalTo(14)
        }
        
        lastChatLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.trailing.equalTo(-12)
            make.bottom.equalTo(profileImageView.snp.bottom).priority(.low)
        }
    }
}
