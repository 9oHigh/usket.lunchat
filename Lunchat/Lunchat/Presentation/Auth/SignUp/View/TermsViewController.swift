//
//  TermsViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/04.
//

import UIKit
import RxSwift

final class TermsViewController: BaseViewController {
    
    private let totalView = TermsView(termType: .total)
    private let personalView = TermsView(termType: .personal)
    private let termOfUseView = TermsView(termType: .termOfUse)
    private let locationView = TermsView(termType: .location)
    private let marketingView = TermsView(termType: .marketing)
    private let startButton = LunchatButton()
    
    private let viewModel: TermsViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: TermsViewModel) {
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
        setConstraint()
        bind()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.termType, object: nil, queue: .main) { [weak self] noti in
            if let type = noti.userInfo?["termType"] as? TermType {
                switch type {
                case .total, .marketing:
                    return
                case .personal:
                    self?.personalView.setActive()
                case .termOfUse:
                    self?.termOfUseView.setActive()
                case .location:
                    self?.locationView.setActive()
                }
                self?.isAllChecked()
                self?.isCheckedWithoutNoti()
            }
        }
    }
    
    private func setConfig() {
        startButton.setTitle("동의하고 시작하기", for: .normal)
        startButton.setFont(of: 20)
        startButton.setInActive()
        startButton.isEnabled = false
    }
    
    private func setUI() {
        view.addSubview(totalView)
        view.addSubview(personalView)
        view.addSubview(termOfUseView)
        view.addSubview(locationView)
        view.addSubview(marketingView)
        view.addSubview(startButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        totalView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(24)
            make.centerX.equalToSuperview()
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(32)
        }
        
        personalView.snp.makeConstraints { make in
            make.top.equalTo(totalView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        termOfUseView.snp.makeConstraints { make in
            make.top.equalTo(personalView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        locationView.snp.makeConstraints { make in
            make.top.equalTo(termOfUseView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        marketingView.snp.makeConstraints { make in
            make.top.equalTo(locationView.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(20)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(inset > 20 ? view.safeAreaLayoutGuide.snp.bottomMargin : -12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(62)
        }
    }
    
    private func bind() {

        Observable.merge([
            termOfUseView.getDeatilButtonObservable(),
            locationView.getDeatilButtonObservable(),
            personalView.getDeatilButtonObservable()
        ])
        .subscribe(onNext: { [weak self] type in
            self?.viewModel.showDetailTerm(type: type)
        })
        .disposed(by: disposeBag)

        Observable.merge([
            personalView.getCheckObservable().skip(1),
            termOfUseView.getCheckObservable().skip(1),
            locationView.getCheckObservable().skip(1)
        ])
        .subscribe(onNext: { [weak self] _ in
            self?.viewModel.showInvalidConfirm()
        })
        .disposed(by: disposeBag)
        
        totalView.getCheckObservable().skip(1).subscribe({ [weak self] _ in
            guard let self = self else { return }
            if self.isAllChecked() {
                self.totalView.setInActive()
                self.personalView.setInActive()
                self.termOfUseView.setInActive()
                self.locationView.setInActive()
                self.marketingView.setInActive()
                self.startButton.setInActive()
            } else if self.isCheckedWithoutNoti() {
                self.marketingView.setActive()
            } else {
                self.viewModel.showInvalidConfirm()
            }
        })
        .disposed(by: disposeBag)

        marketingView.getCheckObservable().skip(1).subscribe({ [weak self] _ in
            guard let self = self else { return }
            
            if self.marketingView.isActive() {
                self.marketingView.setInActive()
            } else {
                self.marketingView.setActive()
            }
            self.isAllChecked()
            self.isCheckedWithoutNoti()
        })
        .disposed(by: disposeBag)
        
        startButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            if self.isAllChecked() {
                self.viewModel.setAgreeMargeting(isAgree: true)
            } else {
                self.viewModel.setAgreeMargeting(isAgree: false)
            }
            self.viewModel.signupWithKakao()
        })
        .disposed(by: disposeBag)
    }
    
    @discardableResult
    private func isCheckedWithoutNoti() -> Bool {
        if personalView.isActive() && termOfUseView.isActive() && locationView.isActive() {
            startButtonSetActive()
            return true
        } else {
            startButtonSetInActive()
            return false
        }
    }
    
    @discardableResult
    private func isAllChecked() -> Bool {
        if personalView.isActive() && termOfUseView.isActive() && locationView.isActive() && marketingView.isActive() {
            totalView.setActive()
            startButtonSetActive()
            return true
        } else {
            totalView.setInActive()
            startButtonSetInActive()
            return false
        }
    }
    
    private func startButtonSetActive() {
        startButton.setActive()
        startButton.isEnabled = true
    }
    
    private func startButtonSetInActive() {
        startButton.setInActive()
        startButton.isEnabled = false
    }
}
