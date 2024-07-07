//
//  AppointmentDetailInfoView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/05.
//

import UIKit

enum AppointmentDetailInfoType: String {
    case restaurant
    case menu
    case time
    case remainTime
    case distance
    
    var title: String? {
        switch self {
        case .restaurant:
            return nil
        case .menu:
            return "메뉴"
        case .time:
            return "밥약시간"
        case .remainTime:
            return "남은시간"
        case .distance:
            return "나와의 거리"
        }
    }
}

final class AppointmentDetailInfoView: UIView {
    
    private let type: AppointmentDetailInfoType
    private let infoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private var fromSearch: Bool
    
    init(type: AppointmentDetailInfoType, fromSearch: Bool = false) {
        self.type = type
        self.fromSearch = fromSearch
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        infoImageView.image = UIImage(named: self.type.rawValue)
        infoImageView.contentMode = .scaleAspectFit
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        titleLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 13 : 11)
        titleLabel.textColor = AppColor.grayText.color
        titleLabel.text = type.title
        titleLabel.numberOfLines = 0
        
        infoLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 13 : 11)
        infoLabel.textColor = AppColor.black.color
        infoLabel.numberOfLines = 0
        
        if fromSearch {
            titleLabel.font = AppFont.shared.getBoldFont(size: 15)
            infoLabel.font = AppFont.shared.getBoldFont(size: 15)
        }
    }
    
    private func setUI() {
        addSubview(infoImageView)
        addSubview(titleLabel)
        addSubview(infoLabel)
    }
    
    private func setConstraint() {
        infoImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(infoImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(infoImageView.snp.trailing).offset(12)
            if fromSearch {
                make.width.equalTo(124)
            } else {
                make.width.equalTo(70)
            }
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setInfoText(text: String) {
        self.infoLabel.text = text
    }
}
