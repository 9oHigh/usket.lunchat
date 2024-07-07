//
//  PermissionItem.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/12.
//

import UIKit

enum PermissionItemType: String {
    case location
    case camera
    case photo
    case notification
    
    var title: String {
        switch self {
        case .location:
            return "위치정보"
        case .camera:
            return "카메라"
        case .photo:
            return "사진첩"
        case .notification:
            return "알림"
        }
    }
    
    var subTitle: String {
        switch self {
        case .location:
            return "밥약 생성 / 밥약과 내 위치 거리 확인"
        case .camera:
            return "프로필 사진 변경, 맛집공유 사진 첨부"
        case .photo:
            return "프로필 사진 변경, 맛집공유 사진 첨부"
        case .notification:
            return "채팅 알림, 공지사항 알림"
        }
    }
}

final class PermissionItem: UIView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    let type: PermissionItemType
    
    init(_ type: PermissionItemType) {
        self.type = type
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "permission_\(type.rawValue)")
        
        titleLabel.font = AppFont.shared.getRegularFont(size: 14)
        titleLabel.text = type.title
        titleLabel.textColor = AppColor.black.color
        
        subTitleLabel.font = AppFont.shared.getRegularFont(size: 12)
        subTitleLabel.text = type.subTitle
        subTitleLabel.textColor = AppColor.grayText.color
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(12)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(12)
        }
    }
}
