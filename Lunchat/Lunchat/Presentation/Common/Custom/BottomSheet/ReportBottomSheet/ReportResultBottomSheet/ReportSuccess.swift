//
//  ReportSuccess.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/12.
//

import UIKit
import RxSwift

final class ReportSuccess: DefaultBaseBottomSheet {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(.success)
        setButtons(.center)
        setConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.setConstraints()
            self.contentView.frame.origin.y = self.contentView.frame.height
        }
    }
    
    private func setConfig() {
        titleLabel.text = "신고접수가 완료되었습니다"
        detailLabel.text = "신고내용은 운영팀에서 확인 후 조치 예정입니다.\n회원님의 관심으로 좋은 LunChat을 만들겠습니다."
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(240 + bottomInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
        }
        
        centerCheckButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.912)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.104)
        }
    }
    
    func getButtonObservable() -> Observable<Void> {
        return centerCheckButton.rx.tap.asObservable()
    }
}
