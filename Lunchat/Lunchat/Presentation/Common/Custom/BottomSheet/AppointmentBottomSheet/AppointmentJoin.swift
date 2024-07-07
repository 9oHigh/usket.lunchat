//
//  AppointmentJoinBottomSheet.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/05.
//

import UIKit
import RxSwift

final class AppointmentJoin: DefaultBaseBottomSheet {

    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(.question)
        setButtons(.divided)
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
        titleLabel.text = "밥약에 참여하시겠습니까?"
        detailLabel.text = "밥약 시간을 꼭 준수해 주세요.\n시간을 지키지 않을 경우 패널티가 부여 될 수 있습니다."
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(256 + bottomInset)
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
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.453)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.104)
            make.centerX.equalToSuperview().multipliedBy(0.525)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
        
        checkButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.453)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.104)
            make.centerX.equalToSuperview().multipliedBy(1.475)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    func getCancelButtonObservable() -> Observable<Void> {
        return cancelButton.rx.tap.asObservable()
    }
    
    func getCheckButtonObservable() -> Observable<Void> {
        return checkButton.rx.tap.asObservable()
    }
}
