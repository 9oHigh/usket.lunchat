//
//  AppointmentChatCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/17.
//

import UIKit

final class AppointmentChatCell: UITableViewCell {
    
    static let identifier = "AppointmentChatCell"
    private var profileImageViews = MultiProfileImageView()
    private let nicknameLabel = UILabel()
    private let memberCountLabel = UILabel()
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
        self.profileImageViews.resetImageView()
        self.nicknameLabel.text = nil
        self.lastChatLabel.text = nil
        self.memberCountLabel.text = nil
    }
    
    func setDataSource(chatRoom: ChatRoom) {
        
        self.chatRoom = chatRoom
        
        if chatRoom.isClosed {
            let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            let subImageView = UIImageView(image: UIImage(named: "closedChat"))
            
            visualEffectView.clipsToBounds = true
            visualEffectView.layer.cornerRadius = 5
            subImageView.contentMode = .scaleAspectFit
            backgroundColor = UIColor.init(hex: "#F0F0F0")
            
            DispatchQueue.main.async {
                self.profileImageViews.setImages(participants: chatRoom.participants)
                self.profileImageViews.setInitialize()
                self.profileImageViews.addSubview(visualEffectView)
                visualEffectView.frame = self.profileImageViews.bounds
                
                self.profileImageViews.addSubview(subImageView)
                subImageView.snp.makeConstraints {
                    $0.width.height.equalToSuperview().multipliedBy(0.5)
                    $0.center.equalToSuperview()
                }
            }
            
            nicknameLabel.text = "종료된 채팅입니다."
            nicknameLabel.textColor = AppColor.deepGrayText.color
            lastChatLabel.text = "종료된 채팅입니다.\n채팅이 종료되었어도 이전기록은 확인이 가능합니다."
            lastChatLabel.font = AppFont.shared.getRegularFont(size: 10)
            memberCountLabel.isHidden = true
        } else {
            profileImageViews.setImages(participants: chatRoom.participants)
            profileImageViews.setInitialize()
            
            memberCountLabel.text = "\(chatRoom.currParticipants)/\(chatRoom.maxParticipants)"
            
            var nicknameString: String = ""
            for index in 0 ..< chatRoom.participants.count {
                if index == chatRoom.participants.count - 1 {
                    nicknameString += "\(chatRoom.participants[index].nickname)"
                } else {
                    nicknameString += "\(chatRoom.participants[index].nickname),"
                }
            }
            
            nicknameLabel.text = nicknameString
            nicknameLabel.textColor = AppColor.black.color
            lastChatLabel.font = AppFont.shared.getRegularFont(size: 14)
            
            if let lastMessage = chatRoom.lastMessage?.content{
                lastChatLabel.text = lastMessage
            } else {
                lastChatLabel.text = "채팅을 시작해보세요!"
            }
            
            memberCountLabel.isHidden = false
        }
    }
    
    func getDataSource() -> ChatRoom? {
        if let chatRoom = self.chatRoom {
            return chatRoom
        }
        return nil
    }
    
    private func setConfig() {
        selectionStyle = .none
        memberCountLabel.font = AppFont.shared.getBoldFont(size: 12)
        memberCountLabel.textColor = AppColor.deepGrayText.color
        
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 16)
        nicknameLabel.textColor = AppColor.black.color
        nicknameLabel.numberOfLines = 1
        
        lastChatLabel.font = AppFont.shared.getRegularFont(size: 14)
        lastChatLabel.textColor = AppColor.thinGrayText.color
        lastChatLabel.numberOfLines = 2
    }
    
    private func setUI() {
        contentView.addSubview(profileImageViews)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(memberCountLabel)
        contentView.addSubview(lastChatLabel)
    }
    
    private func setConstraint() {
        profileImageViews.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.leading.equalTo(12)
            make.width.equalTo(profileImageViews.snp.height)
            make.bottom.equalTo(-14)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageViews.snp.trailing).offset(16)
            make.width.lessThanOrEqualTo(130)
            make.top.equalTo(14)
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel.snp.centerY)
            make.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
        }
        
        lastChatLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageViews.snp.trailing).offset(16)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.trailing.equalTo(-12)
            make.bottom.equalTo(profileImageViews.snp.bottom).priority(.low)
        }
    }
}
