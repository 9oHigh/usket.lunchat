//
//  AppointmentMenuViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class AppointmentMenuViewController: BaseViewController {
    
    private let titleLabel = UILabel()
    private let koreanMenuView = MenuInfoView(menuType: .korean)
    private let japanMenuView = MenuInfoView(menuType: .japanese)
    private let chinaMenuView = MenuInfoView(menuType: .chinese)
    private let westernMenuView = MenuInfoView(menuType: .western)
    private let nextButton = LunchatButton()
    
    private let viewModel: CreateAppointmentViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: CreateAppointmentViewModel) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBottomLine()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
        if isMovingFromParent {
            viewModel.finishCoordinator()
        }
    }
    
    private func setConfig() {
        titleLabel.text = "메뉴를 선택해 주세요"
        titleLabel.font = AppFont.shared.getBoldFont(size: 18)
        titleLabel.textColor = AppColor.black.color
        
        nextButton.setFont(of: 16)
        nextButton.setTitle("다음", for: .normal)
        nextButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(titleLabel)
        view.addSubview(koreanMenuView)
        view.addSubview(japanMenuView)
        view.addSubview(chinaMenuView)
        view.addSubview(westernMenuView)
        view.addSubview(nextButton)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.leading.equalTo(16)
        }
        
        koreanMenuView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        japanMenuView.snp.makeConstraints { make in
            make.top.equalTo(koreanMenuView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        chinaMenuView.snp.makeConstraints { make in
            make.top.equalTo(japanMenuView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        westernMenuView.snp.makeConstraints { make in
            make.top.equalTo(chinaMenuView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        koreanMenuView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.koreanMenuView.setChecked()
            self?.japanMenuView.setUnChecked()
            self?.chinaMenuView.setUnChecked()
            self?.westernMenuView.setUnChecked()
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        japanMenuView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.koreanMenuView.setUnChecked()
            self?.japanMenuView.setChecked()
            self?.chinaMenuView.setUnChecked()
            self?.westernMenuView.setUnChecked()
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        chinaMenuView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.koreanMenuView.setUnChecked()
            self?.japanMenuView.setUnChecked()
            self?.chinaMenuView.setChecked()
            self?.westernMenuView.setUnChecked()
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        westernMenuView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.koreanMenuView.setUnChecked()
            self?.japanMenuView.setUnChecked()
            self?.chinaMenuView.setUnChecked()
            self?.westernMenuView.setChecked()
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .map { owner, _ in
                let menuArray = [owner.koreanMenuView, owner.japanMenuView, owner.chinaMenuView, owner.westernMenuView]
                for menu in menuArray {
                    if !menu.getIsHidden() {
                        return menu.getMenuType()
                    }
                }
                return MenuType.korean
            }
            .subscribe({ [weak self] type in
                if let menuType = type.element {
                    self?.viewModel.showTimeViewController(menuType: menuType)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
