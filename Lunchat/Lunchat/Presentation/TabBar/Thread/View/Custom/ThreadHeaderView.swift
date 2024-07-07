//
//  ThreadHeaderView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import UIKit
import RxSwift
import RxCocoa

final class ThreadHeaderView: UIView {
    
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let addressLabel = UILabel()
    private let myPostButton = UIButton(type: .custom)
    private let notificationButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [AppColor.headerPurple.color.cgColor, AppColor.headerWhite.color.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
        
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = AppColor.white.color.cgColor
        profileImageView.layer.borderWidth = 1
        
        nicknameLabel.text = UserDefaults.standard.getUserInfo(.nickname) ?? "닉네임"
        nicknameLabel.textColor = AppColor.white.color
        nicknameLabel.font = AppFont.shared.getBoldFont(size: 18)
        
        addressLabel.font = AppFont.shared.getBoldFont(size: 11)
        addressLabel.textColor = AppColor.white.color
        addressLabel.text = "주소"
        
        myPostButton.setImage(UIImage(named: "my_post"), for: .normal)
        myPostButton.contentMode = .scaleAspectFit
        
        notificationButton.setImage(UIImage(named: "emptyNotification"), for: .normal)
        notificationButton.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(addressLabel)
        addSubview(myPostButton)
        addSubview(notificationButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalToSuperview().offset(inset > 20 ? inset/2 : 8)
            make.width.equalToSuperview().multipliedBy(0.12)
            make.height.equalTo(profileImageView.snp.width)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.bottom.equalTo(addressLabel.snp.top).offset(-4)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.bottom.equalTo(profileImageView.snp.bottom)
        }
        
        myPostButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.trailing.equalTo(notificationButton.snp.leading).offset(-12)
            make.width.height.equalTo(profileImageView.snp.width).multipliedBy(0.56)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.trailing.equalTo(-12)
            make.width.height.equalTo(profileImageView.snp.width).multipliedBy(0.56)
        }
    }
    
    func getNotificationButtonObservable() -> Observable<Void> {
        return notificationButton.rx.tap.asObservable()
    }
    
    func getMyPostButtonObservable() -> Observable<Void> {
        return myPostButton.rx.tap.asObservable()
    }
    
    func setDataSource(_ userInfo: UserInformation) {
        DispatchQueue.main.async {
            self.addressLabel.text = userInfo.area
            self.nicknameLabel.text = userInfo.nickname
            
            if userInfo.hasUnreadNotification {
                self.notificationButton.setImage(UIImage(named: "remainNotification"), for: .normal)
            } else {
                self.notificationButton.setImage(UIImage(named: "emptyNotification"), for: .normal)
            }
            
            if let profilePicture = userInfo.profilePicture {
                DispatchQueue.main.async {
                    self.profileImageView.loadImageFromUrl(url: URL(string: profilePicture))
                }
            }
        }
    }
}
