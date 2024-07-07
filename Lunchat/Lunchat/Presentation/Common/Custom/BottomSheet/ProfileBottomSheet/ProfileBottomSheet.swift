//
//  ProfileBottomSheet.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/04.
//

import UIKit
import RxSwift
import RxGesture

final class ProfileBottomSheet: BaseViewController {
    
    private let contentView = UIView()
    private let profileInformationView = ProfileInformationView()
    private let sendView = ProfileItemView(itemName: "send", itemTitle: "쪽지 보내기")
    private let reportView = ProfileItemView(itemName: "siren", itemTitle: "신고하기")
    
    private let viewModel: ProfileBottomSheetViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: ProfileBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        bind()
        showLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.setConstraints()
            self.contentView.frame.origin.y = self.contentView.frame.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }

    private func setConfig() {
        view.backgroundColor = AppColor.black.color.withAlphaComponent(0.45)
        contentView.backgroundColor = AppColor.white.color
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = 5
    }
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.addSubview(profileInformationView)
        contentView.addSubview(sendView)
        contentView.addSubview(reportView)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            contentView.frame.origin.y = keyWindow.bounds.size.height
        }
    }
    
    private func setConstraints() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        contentView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(bottomInset > 20 ?  0.6895 : 0.825).offset(bottomInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        profileInformationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(bottomInset > 20 ?  0.65 : 0.725)
        }
        
        sendView.snp.makeConstraints { make in
            make.top.equalTo(profileInformationView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(profileInformationView.snp.height).multipliedBy(0.11)
        }
        
        reportView.snp.makeConstraints { make in
            make.top.equalTo(sendView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(sendView.snp.height)
        }
    }
    
    func bind() {
        let input = ProfileBottomSheetViewModel.Input(
            useTicketSignal: sendView.rx.tapGesture()
                .withUnretained(self)
                .map{ owner, _ in () }
                .asSignal(onErrorJustReturn: ()),
            reportUserSignal: reportView.rx.tapGesture()
                .withUnretained(self)
                .map{ owner, _ in () }
                .asSignal(onErrorJustReturn: ()))
        
        let output = viewModel.transform(input: input)
        
        output.profile.subscribe (onNext: { [weak self] profileInfo in
            
            self?.hideLoadingView(0)
            
            if let profile = profileInfo {
                self?.profileInformationView.setProfileInfo(profileInfo: profile)
            }
        })
        .disposed(by: disposeBag)
    }

    func getViewTapGesture() -> Observable<Void> {
        return view.rx.tapGesture()
            .withUnretained(self)
            .map{ owner, _ in () }
            .asObservable()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
