//
//  ProfileViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class ProfileViewController: BaseViewController {
    
    private let profileInformationView = ProfileInformationView()
    private let profileEditView = ProfileItemView(itemName: "reviseProfile", itemTitle: "프로필 수정")
    private let ticketShopView = ProfileItemView(itemName: "ticketShop", itemTitle: "쪽지샵")
    private let settingView = ProfileItemView(itemName: "setting", itemTitle: "설정 및 개인정보")
    
    private let viewModel: ProfileViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        viewModel.getUserProfile(nickname: UserDefaults.standard.getUserInfo(.nickname) ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraint()
        bind()
        showLoadingView()
    }
    
    private func setUI() {
        view.addSubview(profileInformationView)
        view.addSubview(profileEditView)
        view.addSubview(ticketShopView)
        view.addSubview(settingView)
    }
    
    private func setConstraint() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        profileInformationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(bottomInset > 20 ?  0.465 : 0.525)
        }
        
        profileEditView.snp.makeConstraints { make in
            make.top.equalTo(profileInformationView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(profileInformationView.snp.height).multipliedBy(0.118)
        }
        
        ticketShopView.snp.makeConstraints { make in
            make.top.equalTo(profileEditView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(profileEditView.snp.height)
        }
        
        settingView.snp.makeConstraints { make in
            make.top.equalTo(ticketShopView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(profileEditView.snp.height)
        }
    }
    
    private func bind() {
        let input = ProfileViewModel.Input(
            editProfileSign: profileEditView.rx.tapGesture().when(.recognized)
                .map { _ in }.asSignal(onErrorJustReturn: ()),
            goToShopSign: ticketShopView.rx.tapGesture().when(.recognized)
                .map { _ in }.asSignal(onErrorJustReturn: ()),
            goToSettingSign: settingView.rx.tapGesture().when(.recognized)
                .map { _ in }.asSignal(onErrorJustReturn: ()), profileSign: Signal<Void>.just(()))
        
        let output = viewModel.transform(input: input)
        
        output.profile
            .withUnretained(self)
            .compactMap({ owner, profile in
                owner.hideLoadingView(0)
                return profile == nil ? nil : profile
            })
            .subscribe({ [weak self] profile in
                if let profile = profile.element {
                    self?.profileInformationView.setProfileInfo(profileInfo: profile)
                }
            })
            .disposed(by: disposeBag)
    }
}
