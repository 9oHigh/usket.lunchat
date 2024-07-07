//
//  NotificationViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewController: BaseViewController, UIScrollViewDelegate {
    
    private let notiBackgroundView = UIView()
    private let notiImageView = UIImageView(image: UIImage(named: "emptyNotification"))
    private let notiLabel = UILabel()
    private let detailNotiLabel = UILabel()
    private let notiSwitch = UISwitch()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private let viewModel: NotificationViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: NotificationViewModel) {
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
        showLoadingView()
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationPermission), name: NSNotification.Name.sceneDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notiSwitch.layoutIfNeeded()
        notiSwitch.layer.cornerRadius = notiSwitch.bounds.height / 2
    }
    
    private func setConfig() {
        notiBackgroundView.backgroundColor = AppColor.purple.color
        notiBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        notiBackgroundView.layer.cornerRadius = 5
        notiBackgroundView.layer.masksToBounds = true
        
        notiImageView.contentMode = .scaleAspectFit
        
        notiLabel.text = "푸시 알림 설정하기"
        notiLabel.textColor = AppColor.white.color
        notiLabel.font = AppFont.shared.getBoldFont(size: 11)
        
        detailNotiLabel.text = "푸시알림은 채팅 및 공지사항에만 적용됩니다."
        detailNotiLabel.textColor = AppColor.white.color
        detailNotiLabel.font = AppFont.shared.getRegularFont(size: 10)
        
        notiSwitch.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        notiSwitch.subviews[0].subviews[0].backgroundColor = AppColor.white.color.withAlphaComponent(0.38)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.tableFooterView = bottomIndicatorView
        tableView.backgroundColor = AppColor.white.color
        tableView.separatorStyle = .none
        tableView.rowHeight = 73
    }
    
    private func setUI() {
        view.addSubview(notiBackgroundView)
        notiBackgroundView.addSubview(notiImageView)
        notiBackgroundView.addSubview(notiLabel)
        notiBackgroundView.addSubview(notiSwitch)
        notiBackgroundView.addSubview(detailNotiLabel)
        view.addSubview(tableView)
    }
    
    private func setConstraint() {
        notiBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.08)
        }
        
        notiImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(18)
            make.width.equalToSuperview().multipliedBy(0.08)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        notiLabel.snp.makeConstraints { make in
            make.centerY.equalTo(notiImageView.snp.centerY).multipliedBy(0.75)
            make.leading.equalTo(notiImageView.snp.trailing).offset(8)
        }
        
        detailNotiLabel.snp.makeConstraints { make in
            make.top.equalTo(notiLabel.snp.bottom).offset(2)
            make.leading.equalTo(notiImageView.snp.trailing).offset(8)
        }
        
        notiSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(notiImageView.snp.width).multipliedBy(1.25)
            make.height.equalTo(notiImageView.snp.height).multipliedBy(0.625)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(notiBackgroundView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = NotificationViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.notifications
            .compactMap { notifications -> [Notification]? in
                self.hideLoadingView(0.25)
                return notifications.isEmpty ? nil : notifications
            }
            .bind(to: tableView.rx.items(cellIdentifier: NotificationTableViewCell.identifier, cellType: NotificationTableViewCell.self)) { [weak self] (row, element, cell) in
                cell.setDataSource(data: element)
            }
            .disposed(by: disposeBag)
        
        output.userInfo.map({ info in
            return info?.allowPushNotification ?? false
        })
        .bind(to: notiSwitch.rx.isOn)
        .disposed(by: disposeBag)
        
        notiSwitch.rx.isOn
            .observe(on: MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                
                let notificationCenter = UNUserNotificationCenter.current()
                
                notificationCenter.getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self.requestNotificationPermission {
                            self.viewModel.getUserInfo()
                        }
                    default:
                        DispatchQueue.main.async {
                            if isOn {
                                self.viewModel.showNotificationAlert()
                                self.notiSwitch.isOn = false
                            } else {
                                self.viewModel.showNotificationCancelAlert()
                                self.notiSwitch.isOn = true
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != 0 {
                    self.viewModel.getMoreNotifications()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading.map(!)
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func requestNotificationPermission(completion: @escaping () -> Void) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { [weak self] (granted, error) in
            if granted {
                self?.viewModel.setUserNotification(true)
                completion()
            } else {
                self?.viewModel.setUserNotification(false)
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    @objc
    private func checkNotificationPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined, .denied:
                self?.viewModel.setUserNotification(false)
            default:
                self?.viewModel.setUserNotification(true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.viewModel.getUserInfo()
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
