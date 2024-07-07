//
//  EmptyView.swift
//  Lunchat
//
//  Created by 이경후 on 5/14/24.
//

import UIKit

enum EmptyType {
    case purchase
    case use
    case thread
    case chat
    
    var title: String {
        switch self {
        case .purchase:
            return "구매내역이 없어요"
        case .use:
            return "사용내역이 없어요"
        case .thread:
            return "쓰레드가 없어요"
        case .chat:
            return "메세지가 없어요"
        }
    }
    
    var subTitle: String {
        switch self {
        case .purchase:
            return "쪽지를 구매해\n사람들과 소통해 보세요."
        case .use:
            return "쪽지를 사용해\n사람들과 소통해 보세요."
        case .thread:
            return "쓰레드를 만들어\n사람들에게 공유해 보세요."
        case .chat:
            return "메세지가 없어요.\n먼저 사람들과 소통해 보세요."
        }
    }
}

final class EmptyView: UIView {
    
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let type: EmptyType
    
    init(type: EmptyType) {
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
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        titleLabel.textColor = AppColor.black.color
        titleLabel.text = type.title
        titleLabel.textAlignment = .center
        
        subLabel.font = AppFont.shared.getRegularFont(size: 13)
        subLabel.numberOfLines = 2
        subLabel.textColor = AppColor.thinGrayText.color
        subLabel.text = type.subTitle
        subLabel.textAlignment = .center
    }
    
    private func setUI() {
        addSubview(titleLabel)
        addSubview(subLabel)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
        
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
