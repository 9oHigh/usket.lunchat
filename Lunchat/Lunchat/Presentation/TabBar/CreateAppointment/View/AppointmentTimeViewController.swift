//
//  AppointmentTimeViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa

final class AppointmentTimeViewController: BaseViewController {
    
    private let headerView = UIView()
    private let headerImageView = UIImageView(image: UIImage(named: "appointmentInfo"))
    private let headerLabel = UILabel()
    
    private let titleLabel = UILabel()
    private let timeInfoView = TimeInfoView()
    private let timePicker = CreateAppointmentTimePicker()
    
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
        headerView.backgroundColor = AppColor.appointmentInfo.color
        headerImageView.contentMode = .scaleAspectFit
        headerLabel.textColor = AppColor.white.color
        headerLabel.font = AppFont.shared.getBoldFont(size: 10)
        headerLabel.text = "밥약 시간을 준수해 주세요. 시간을 지키지 못할시 패널티가 부여됩니다."
        
        titleLabel.text = "밥약 날짜와 시간을 선택해 주세요"
        titleLabel.font = AppFont.shared.getBoldFont(size: 18)
        titleLabel.textColor = AppColor.black.color
        
        let currentDate = Date()
        timeInfoView.backgroundColor = AppColor.white.color
        timeInfoView.setText(date: currentDate)
        
        nextButton.setTitle(currentDate.toCreateAppointmentTime + "예약", for: .normal)
        nextButton.setFont(of: 16)
        nextButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerView.addSubview(headerLabel)
        view.addSubview(titleLabel)
        view.addSubview(timeInfoView)
        view.addSubview(timePicker)
        view.addSubview(nextButton)
    }
    
    private func setConstraint() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        headerImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(12)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(headerImageView.snp.trailing).offset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalTo(16)
        }
        
        timeInfoView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
        
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(timeInfoView.snp.bottom).offset(64)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(120)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        timePicker.getDateObservable()
            .distinctUntilChanged()
            .subscribe({ [weak self] date in
                let koreaTimeZone = TimeZone(identifier: "Asia/Seoul")!
                let koreaLocale = Locale(identifier: "ko_KR")
                if let selectedDate = date.element {
                    let currentTime = Date()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = koreaTimeZone
                    dateFormatter.locale = koreaLocale
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if let selectedDateFormatted = dateFormatter.date(from: dateFormatter.string(from: selectedDate)),
                       let currentTimeFormatted = dateFormatter.date(from: dateFormatter.string(from: currentTime)) {
                        
                        let timeDifference = selectedDateFormatted.timeIntervalSince(currentTimeFormatted)
                        
                        if !(timeDifference > 0 && timeDifference <= 3600) && selectedDate.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                            self?.timeInfoView.setActive()
                            self?.nextButton.setActive()
                            self?.nextButton.isEnabled = true
                        } else {
                            self?.timeInfoView.setInActive()
                            self?.nextButton.setInActive()
                            self?.nextButton.isEnabled = false
                        }
                        
                        self?.timeInfoView.setText(date: selectedDate)
                        self?.nextButton.setTitle(selectedDate.toCreateAppointmentTime + "예약", for: .normal)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .map { owner, _ in
                return owner.timeInfoView.getDate()
            }
            .subscribe({ [weak self] date in
                if let date = date.element {
                    self?.viewModel.showParticipantViewController(date: date)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
