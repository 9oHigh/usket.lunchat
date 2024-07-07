//
//  AppointmentMapViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import NMapsMap
import RxSwift

final class AppointmentMapViewController: BaseViewController, NMFMapViewCameraDelegate {
    
    private let mapView = NMFNaverMapView()
    private let marker = NMFMarker()
    
    private let locationImageView = UIImageView(image: UIImage(named: "location"))
    private let addressLabel = UILabel()
    private let locationButton = LunchatButton()
    
    private let viewModel: CreateAppointmentViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: CreateAppointmentViewModel, lat: Double, long: Double) {
        self.viewModel = viewModel
        self.viewModel.getAddress(lat: lat, long: long)
        
        let cameraPosition = NMFCameraPosition(NMGLatLng(lat: lat, lng: long), zoom: 16)
        let updatedPosition = NMFCameraUpdate(position: cameraPosition)
        self.mapView.mapView.moveCamera(updatedPosition)
        
        let markerPosition = NMGLatLng(lat: lat, lng: long)
        self.marker.position = markerPosition
        self.marker.iconImage = NMFOverlayImage(image: UIImage(named: "locationMarker")!)
        self.marker.mapView = self.mapView.mapView
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
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        self.locationButton.setInActive()
        self.locationButton.isEnabled = false
        
        let target = mapView.cameraPosition.target
        let markerPosition = NMGLatLng(lat: target.lat, lng: target.lng)
        self.marker.position = markerPosition
        self.marker.iconImage = NMFOverlayImage(image: UIImage(named: "locationMarker")!)
        self.marker.mapView = self.mapView.mapView
    }
    
    func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        self.viewModel.getAddress(lat: mapView.latitude, long: mapView.longitude)
    }
    
    private func setConfig() {
        mapView.showLocationButton = true
        mapView.mapView.addCameraDelegate(delegate: self)
        
        locationImageView.contentMode = .scaleAspectFit
        
        addressLabel.font = AppFont.shared.getBoldFont(size: 18)
        addressLabel.textColor = AppColor.black.color
        addressLabel.numberOfLines = 1
        
        locationButton.setTitle("현재 위치로 주소 설정", for: .normal)
        locationButton.setFont(of: 16)
    }
    
    private func setUI() {
        view.addSubview(mapView)
        view.addSubview(locationImageView)
        view.addSubview(addressLabel)
        view.addSubview(locationButton)
    }
    
    private func setConstraint() {
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(locationImageView.snp.top).offset(-16)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.leading.equalTo(16)
            make.bottom.equalTo(locationButton.snp.top).offset(-16)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(locationImageView.snp.centerY)
            make.leading.equalTo(locationImageView.snp.trailing).offset(6)
            make.trailing.equalTo(-16)
        }
        
        locationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        viewModel.mapInfo.subscribe({ [weak self] mapInfo in
            if let info = mapInfo.element, let isEmpty = info?.title.isEmpty, !isEmpty {
                self?.addressLabel.text = info?.roadAddress
                self?.locationButton.setActive()
                self?.locationButton.isEnabled = true
            } else {
                self?.addressLabel.text = "알 수 없는 지역이에요."
                self?.locationButton.setInActive()
                self?.locationButton.isEnabled = false
            }
        })
        .disposed(by: disposeBag)
        
        locationButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            if let chosenPlace = self.viewModel.getChosenPlace() {
                if chosenPlace.title == "" {
                    self.viewModel.showMapChosenFailure()
                } else {
                    let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadLocation, object: nil, userInfo: ["mapInfo":  chosenPlace])
                    NotificationCenter.default.post(notification)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
