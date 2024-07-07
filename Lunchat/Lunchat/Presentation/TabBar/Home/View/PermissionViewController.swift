//
//  PermissionViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/12.
//

import UIKit
import RxSwift

final class PermissionViewController: BaseViewController {
    
    private let contentView = UIView()
    private let permissionLabel = UILabel()
    private let lineView = UIView()
    private let requiredLabel = UILabel()
    private let locationView = PermissionItem(.location)
    private let selectiveLabel = UILabel()
    private let cameraView = PermissionItem(.camera)
    private let photoView = PermissionItem(.photo)
    private let notificationView = PermissionItem(.notification)
    private let explanationLabel = UILabel()
    private let changePermissionLabel = UILabel()
    private let changeExplanationLabel = UILabel()
    private let checkButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
    }
    
    private func setConfig() {
        view.backgroundColor = .clear
        contentView.backgroundColor = AppColor.white.color
        
        permissionLabel.font = AppFont.shared.getRegularFont(size: 18)
        permissionLabel.textColor = AppColor.black.color
        permissionLabel.textAlignment = .center
        permissionLabel.text = "런챗 앱 이용을 위한 권한 안내"
        
        lineView.backgroundColor = AppColor.grayText.color
        
        requiredLabel.font = AppFont.shared.getBoldFont(size: 16)
        requiredLabel.textColor = AppColor.purple.color
        requiredLabel.text = "필수 접근 권한"
        
        locationView.backgroundColor = AppColor.white.color
        
        selectiveLabel.font = AppFont.shared.getBoldFont(size: 16)
        selectiveLabel.textColor = AppColor.purple.color
        selectiveLabel.text = "선택 접근 권한"
        
        cameraView.backgroundColor = AppColor.white.color
        photoView.backgroundColor = AppColor.white.color
        notificationView.backgroundColor = AppColor.white.color
        
        explanationLabel.textColor = AppColor.grayText.color
        explanationLabel.font = AppFont.shared.getRegularFont(size: 12)
        explanationLabel.numberOfLines = 0
        explanationLabel.text = "위 선택 접근권한은 고객님께 더 나은 서비스를 제공하기 위해 사용됩니다. 선택 접근권한은 동의하지 않으셔도 런챗을 이용하실 수 있습니다."
        
        changePermissionLabel.font = AppFont.shared.getBoldFont(size: 12)
        changePermissionLabel.textColor = AppColor.black.color
        changePermissionLabel.text = "접근권한 변경 방법"
        
        changeExplanationLabel.numberOfLines = 0
        changeExplanationLabel.text = "[iOS]\n설정 > 런챗(lunchat) > 권한 설정"
        changeExplanationLabel.font = AppFont.shared.getRegularFont(size: 12)
        
        checkButton.backgroundColor = AppColor.purple.color
        checkButton.setTitle("확인", for: .normal)
        checkButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 16)
    }
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.addSubview(permissionLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(requiredLabel)
        contentView.addSubview(locationView)
        contentView.addSubview(selectiveLabel)
        contentView.addSubview(cameraView)
        contentView.addSubview(photoView)
        contentView.addSubview(notificationView)
        contentView.addSubview(explanationLabel)
        contentView.addSubview(changePermissionLabel)
        contentView.addSubview(changeExplanationLabel)
        contentView.addSubview(checkButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(inset > 20 ? 0.75 : 0.85)
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        permissionLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(permissionLabel.font.pointSize + 4)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(permissionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(24)
            make.leading.equalTo(24)
        }
        
        locationView.snp.makeConstraints { make in
            make.top.equalTo(requiredLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        selectiveLabel.snp.makeConstraints { make in
            make.top.equalTo(locationView.snp.bottom).offset(24)
            make.leading.equalTo(24)
        }
        
        cameraView.snp.makeConstraints { make in
            make.top.equalTo(selectiveLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        photoView.snp.makeConstraints { make in
            make.top.equalTo(cameraView.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        notificationView.snp.makeConstraints { make in
            make.top.equalTo(photoView.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationView.snp.bottom).offset(24)
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
        }
        
        changePermissionLabel.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
        }
        
        changeExplanationLabel.snp.makeConstraints { make in
            make.top.equalTo(changePermissionLabel.snp.bottom).offset(8)
            make.leading.equalTo(24)
        }
        
        checkButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    func getCheckButtonObservable() -> Observable<Void> {
        return checkButton.rx.tap.asObservable()
    }
}
