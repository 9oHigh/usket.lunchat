//
//  NoSharedThreadView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/25.
//

import UIKit
import RxSwift
import RxCocoa

enum NoThreadType {
    case shared
    case liked
    
    var title: String {
        switch self {
        case .shared:
            return "공유한 쓰레드가 없습니다"
        case .liked:
            return "좋아요를 누른 쓰레드가 없습니다"
        }
    }
}

final class NoThreadView: UIView {
    
    private let markImageView = UIImageView(image: UIImage(named: "noResult"))
    private let noThreadLabel = UILabel()
    private let newThreadButton = LunchatButton()
    private let type: NoThreadType
    
    init(type: NoThreadType) {
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
        markImageView.contentMode = .scaleAspectFit
        
        noThreadLabel.font = AppFont.shared.getBoldFont(size: 16)
        noThreadLabel.textColor = AppColor.black.color
        noThreadLabel.text = type.title
        noThreadLabel.textAlignment = .center
        
        newThreadButton.setTitle("맛집 공유", for: .normal)
        newThreadButton.setActive()
        newThreadButton.setFont(of: 16)
        newThreadButton.isEnabled = true
    }
    
    private func setUI() {
        addSubview(markImageView)
        addSubview(noThreadLabel)
        addSubview(newThreadButton)
    }
    
    private func setConstraint() {
        
        markImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.85)
            make.width.height.equalTo(60)
        }
        
        noThreadLabel.snp.makeConstraints { make in
            make.top.equalTo(markImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
        }
        
        if type == .shared {
            newThreadButton.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalTo(16)
                make.trailing.equalTo(-16)
                make.height.equalTo(44)
            }
        }
    }
    
    func getNewThreadButtonObservable() -> Observable<Void> {
        return newThreadButton.rx.tap.asObservable()
    }
}
