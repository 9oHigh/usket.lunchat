//
//  TermsView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/04.
//

import UIKit
import RxSwift
import RxGesture

enum TermType: CaseIterable {
    case total
    case personal
    case termOfUse
    case location
    case marketing
    
    var title: String {
        switch self {
        case .total:
            return "전체동의"
        case .personal:
            return "개인정보의 수집 및 이용 동의 (필수)"
        case .termOfUse:
            return "LunChat 서비스 이용약관 동의 (필수)"
        case .location:
            return "LunChat 위치기반 서비스 이용약관 동의 (필수)"
        case .marketing:
            return "이벤트 진행, 개인 맞춤형 서비스 제공 및 기타 광고성 정보 제공을 위한, 마케팅 정보 수신 동의 (선택)"
        }
    }
    
    var inActiveFont: UIFont {
        switch self {
        case .total:
            return AppFont.shared.getRegularFont(size: 18)
        case .personal, .termOfUse, .location, .marketing:
            return AppFont.shared.getRegularFont(size: 12)
        }
    }
    
    var activeFont: UIFont {
        switch self {
        case .total:
            return AppFont.shared.getBoldFont(size: 18)
        case .personal, .termOfUse, .location, .marketing:
            return AppFont.shared.getBoldFont(size: 12)
        }
    }
    
    var navigationTitle: String? {
        switch self {
        case .total, .marketing:
            return nil
        case .personal:
            return "개인정보 수집 및 이용 동의"
        case .termOfUse:
            return "서비스 이용약관 이용 동의"
        case .location:
            return "위치 서비스 이용약관 동의"
        }
    }
    
    var url: URL? {
        switch self {
        case .total, .marketing:
            return nil
        case .personal:
            return URL(string: "https://home.lunchat.co/privacy-policy.html")
        case .termOfUse:
            return URL(string: "https://home.lunchat.co/terms-of-service.html")
        case .location:
            return URL(string: "https://home.lunchat.co/location-base-terms-of-service.html")
        }
    }
}

final class TermsView: UIView {
    
    private let checkImageView = UIImageView(image: UIImage(named: "unCheck"))
    private let titleLabel = UILabel()
    
    private let detailButton = UIButton()
    private let bottomLine = UIView()
    
    private let termType: TermType
    
    init(termType: TermType){
        self.termType = termType
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        backgroundColor = AppColor.white.color
        checkImageView.contentMode = .scaleAspectFill
        
        titleLabel.text = termType.title
        titleLabel.font = termType.inActiveFont
        titleLabel.numberOfLines = 0
        
        if termType == .total {
            bottomLine.backgroundColor = AppColor.textField.color
        } else if termType == .marketing {
            detailButton.isHidden = true
        } else {
            detailButton.imageView?.contentMode = .scaleAspectFill
            detailButton.setImage(UIImage(named: "term_push"), for: .normal)
        }
    }
    
    private func setUI() {
        addSubview(checkImageView)
        addSubview(titleLabel)
        
        if termType == .total {
            addSubview(bottomLine)
        } else {
            addSubview(detailButton)
        }
    }
    
    private func setConstraint() {
        if termType == .total {
            checkImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(checkImageView.snp.trailing).offset(16)
                make.centerY.equalTo(checkImageView.snp.centerY)
            }
            
            bottomLine.snp.makeConstraints { make in
                make.height.equalTo(3)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            checkImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(checkImageView.snp.trailing).offset(16)
                make.centerY.equalToSuperview()
                make.trailing.equalTo(detailButton.snp.leading).offset(16)
            }
            
            detailButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(44)
            }
        }
    }
    
    func getDeatilButtonObservable() -> Observable<TermType> {
        
        return Observable.merge(
            detailButton.rx.tap.skip(1)
                .withUnretained(self)
                .map { owner, _ in owner.termType },
            titleLabel.rx.tapGesture().skip(1)
                .withUnretained(self)
                .map { owner, _ in owner.termType }
        )
        .asObservable()
    }
    
    func getCheckObservable() -> Observable<Void> {
        return checkImageView.rx.tapGesture().map { _ in }.asObservable()
    }
    
    func setActive() {
        if termType == .total {
            checkImageView.image = UIImage(named: "check")
            titleLabel.font = AppFont.shared.getBoldFont(size: 18)
            bottomLine.backgroundColor = AppColor.purple.color
        } else {
            checkImageView.image = UIImage(named: "check")
            titleLabel.font = AppFont.shared.getBoldFont(size: 12)
        }
    }
    
    func setInActive() {
        if termType == .total {
            checkImageView.image = UIImage(named: "unCheck")
            titleLabel.font = AppFont.shared.getRegularFont(size: 18)
            bottomLine.backgroundColor = AppColor.textField.color
        } else {
            checkImageView.image = UIImage(named: "unCheck")
            titleLabel.font = AppFont.shared.getRegularFont(size: 12)
        }
    }
    
    func isActive() -> Bool {
        if checkImageView.image == UIImage(named: "check") {
            return true
        }
        return false
    }
}
