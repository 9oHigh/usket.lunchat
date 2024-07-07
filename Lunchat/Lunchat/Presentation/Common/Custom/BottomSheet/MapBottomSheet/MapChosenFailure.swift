//
//  MapChosenFailure.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/09.
//

import UIKit
import RxSwift

final class MapChosenFailure: DefaultBaseBottomSheet {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(.failure)
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
        titleLabel.text = "알 수 없는 장소입니다."
        detailLabel.text = "정확한 장소로 지정해주세요."
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(232 + bottomInset)
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
