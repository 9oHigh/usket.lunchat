//
//  AppointmentParticipantViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa

final class AppointmentParticipantViewController: BaseViewController {
    
    private let titleLabel = UILabel()
    private let twoParticipantView = ParticipantView(participantCountType: .two)
    private let threeParticipantView = ParticipantView(participantCountType: .three)
    private let fourParticipantView = ParticipantView(participantCountType: .four)
    private let bottomLine = UIView()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
    }
    
    private func setConfig() {
        titleLabel.text = "인원을 선택해 주세요"
        titleLabel.font = AppFont.shared.getBoldFont(size: 18)
        titleLabel.textColor = AppColor.black.color
        
        bottomLine.backgroundColor = AppColor.grayText.color
        
        nextButton.setTitle("다음", for: .normal)
        nextButton.setFont(of: 16)
        nextButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(titleLabel)
        view.addSubview(twoParticipantView)
        view.addSubview(threeParticipantView)
        view.addSubview(fourParticipantView)
        view.addSubview(bottomLine)
        view.addSubview(nextButton)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.leading.equalTo(16)
        }
        
        twoParticipantView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.height.equalTo(44)
            make.width.equalTo(56)
        }
        
        threeParticipantView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(56)
        }
        
        fourParticipantView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.trailing.equalTo(-20)
            make.height.equalTo(44)
            make.width.equalTo(56)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.leading.equalTo(twoParticipantView.snp.leading)
            make.trailing.equalTo(fourParticipantView.snp.trailing)
            make.top.equalTo(twoParticipantView.snp.bottom).offset(4)
            make.height.equalTo(3)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        twoParticipantView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.twoParticipantView.setActive()
            self?.threeParticipantView.setInActive()
            self?.fourParticipantView.setInActive()
            self?.bottomLine.backgroundColor = AppColor.purple.color
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        threeParticipantView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.threeParticipantView.setActive()
            self?.twoParticipantView.setInActive()
            self?.fourParticipantView.setInActive()
            self?.bottomLine.backgroundColor = AppColor.purple.color
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        fourParticipantView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.fourParticipantView.setActive()
            self?.twoParticipantView.setInActive()
            self?.threeParticipantView.setInActive()
            self?.bottomLine.backgroundColor = AppColor.purple.color
            self?.nextButton.setActive()
        })
        .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .map { owner, _ in
                let countArray = [owner.twoParticipantView, owner.threeParticipantView, owner.fourParticipantView]
                for count in countArray {
                    if count.getIsActive() {
                        return count.getType()
                    }
                }
                return ParticipantCountType.four
            }
            .subscribe({ [weak self] type in
                if let type = type.element {
                    self?.viewModel.showLocationViewController(count: type.rawValue)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
