//
//  MainViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/05.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation
import NMapsMap

final class HomeViewController: BaseViewController, UIScrollViewDelegate, UICollectionViewDelegate {
    
    private let headerView = HomeHeaderView()
    private lazy var permissionView = PermissionViewController()
    private var locationManager = CLLocationManager()
    private lazy var homeCollectionView: UICollectionView = {
        let flowLayout = PagingCollectionViewLayout()
        let inset = UserDefaults.standard.getSafeAreaInset()
        let heightRate = inset > 20 ? 0.75 : 0.77
        let width: CGFloat = self.view.frame.width - 60
        let height: CGFloat = self.view.bounds.height * heightRate
        flowLayout.minimumLineSpacing = 13
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 30, bottom: 8, right: 30)
        flowLayout.velocityThresholdPerPage = 10
        flowLayout.itemSize = CGSize(width: width, height: height)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    private let viewModel: HomeViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModel) {
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
        initailizeLocationManager()
        viewModel.getUserSchedule()
        viewModel.getUserInfo()
        showLoadingView()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.reloadAppointments, object: nil, queue: .main) { _ in
            self.showLoadingView()
            self.viewModel.setNeedRefresh(true)
            self.viewModel.getUserInfo()
            if UserStatusTracker.shared.getUserStatus() == .nothing {
                self.viewModel.resetAppointments()
                self.homeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: true)
            } else {
                self.viewModel.getUserSchedule()
            }
            self.checkLocationPermission()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.isFirstAuthorizationPopup() {
            self.setBackground()
            self.permissionView.modalPresentationStyle = .overFullScreen
            self.present(permissionView, animated: true)
        }
    }
    
    private func setConfig() {
        homeCollectionView.delegate = self
        homeCollectionView.backgroundColor = AppColor.white.color
        homeCollectionView.showsHorizontalScrollIndicator = false
        homeCollectionView.register(HomeAppointmentCollectionViewCell.self, forCellWithReuseIdentifier: HomeAppointmentCollectionViewCell.identifier)
        homeCollectionView.register(HomeCreateAppointmentCell.self, forCellWithReuseIdentifier: HomeCreateAppointmentCell.identifier)
    }
    
    private func setUI() {
        view.addSubview(headerView)
        view.addSubview(homeCollectionView)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.0955).offset(inset > 20 ? inset/2 : 8)
            make.leading.trailing.equalToSuperview()
        }
        
        homeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0))
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = HomeViewModel.Input(toNotificationSignal: headerView.getNotificationButtonObservable().asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input: input)
        
        output.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                self?.hideLoadingView(0.75)
                self?.headerView.setDataSource(userInfo)
            })
            .disposed(by: disposeBag)
        
        output.appointments
            .map { appointments -> [Appointment] in
                if UserStatusTracker.shared.getUserStatus() == .made ||
                    UserStatusTracker.shared.getUserStatus() == .participated {
                    return appointments
                } else {
                    if appointments.isEmpty {
                        return [Appointment.empty]
                    } else {
                        var appointmentsList = appointments
                        var term: Int = 0
                        
                        for index in 0 ..< appointmentsList.count {
                            if index % 5 == 0 && index != 0 {
                                appointmentsList.insert(Appointment.recommend, at: index + term)
                                term += 1
                            }
                        }
                        if self.viewModel.isLastAppointment() {
                            appointmentsList.append(Appointment.empty)
                        }
                        return appointmentsList
                    }
                }
            }
            .bind(to: homeCollectionView.rx.items) { [weak self] (collectionView, index, item) in
                guard let self = self else { return UICollectionViewCell() }
                
                self.hideLoadingView(0)
                
                if item == Appointment.empty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCreateAppointmentCell.identifier, for: IndexPath(row: index, section: 0)) as? HomeCreateAppointmentCell
                    cell?.setType(type: .empty)
                    cell?.setCreateButtonAction(viewModel: self.viewModel.getHomeCreateAppointmentCellViewModel())
                    return cell ?? UICollectionViewCell()
                } else if item == Appointment.recommend {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCreateAppointmentCell.identifier, for: IndexPath(row: index, section: 0)) as? HomeCreateAppointmentCell
                    cell?.setType(type: .recommend)
                    cell?.setCreateButtonAction(viewModel: self.viewModel.getHomeCreateAppointmentCellViewModel())
                    return cell ?? UICollectionViewCell()
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAppointmentCollectionViewCell.identifier, for: IndexPath(row: index, section: 0)) as? HomeAppointmentCollectionViewCell
                    cell?.setDataSource(appointment: item, viewModel: self.viewModel.getHomeAppointmentCellViewModel())
                    return cell ?? UICollectionViewCell()
                }
            }
            .disposed(by: disposeBag)
        
        homeCollectionView.rx.didScroll
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let lastVisibleIndexPath = self.homeCollectionView.indexPathsForVisibleItems.last
                let lastItem = (self.viewModel.getAppointmentCount() ?? 0)
                
                if let lastVisibleIndexPath = lastVisibleIndexPath, lastVisibleIndexPath.item == lastItem {
                    self.viewModel.loadMoreAppointment()
                }
            })
            .disposed(by: disposeBag)
        
        if UserDefaults.standard.isFirstAuthorizationPopup() {
            permissionView.getCheckButtonObservable().subscribe({ [weak self] _ in
                UserDefaults.standard.setUserInfo(.isFirstAuthorizationPopup, data: "false")
                self?.unsetBackground()
                self?.dismiss(animated: true) {
                    self?.locationManager.requestWhenInUseAuthorization()
                    self?.registerForRemoteNotifications()
                }
            })
            .disposed(by: disposeBag)
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController: CLLocationManagerDelegate, NMFMapViewCameraDelegate {
    
    private func initailizeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
    }
    
    private func checkLocationPermission() {
        
        switch locationManager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            viewModel.showLocationPermission()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            updateUserCoords()
        @unknown default:
            viewModel.showLocationPermission()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            viewModel.showLocationPermission()
        case .restricted, .denied:
            viewModel.showLocationPermission()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            updateUserCoords()
        @unknown default:
            viewModel.showLocationPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUserCoords()
    }
    
    private func updateUserCoords() {
        guard let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            return
        }
        
        let coords = Coordinate(latitude: String(latitude), longitude: String(longitude))
        viewModel.setUserCoords(coords: coords)
        viewModel.getUserInfo()
    }
}

extension HomeViewController: UNUserNotificationCenterDelegate {
    
    private func registerForRemoteNotifications() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            guard granted
            else {
                self.viewModel.setUserNotification(isAllowed: false)
                return
            }
            
            self.viewModel.setUserNotification(isAllowed: true)
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
