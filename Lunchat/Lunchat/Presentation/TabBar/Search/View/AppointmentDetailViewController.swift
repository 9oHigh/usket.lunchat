//
//  AppointmentDetailViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/05.
//

import UIKit
import NMapsMap
import RxSwift
import RxCocoa

final class AppointmentDetailViewController: BaseViewController, UICollectionViewDelegate {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = AppColor.white.color
        return scrollView
    }()
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.white.color
        return view
    }()
    
    private let mapView = NMFNaverMapView()
    
    private let titleLabel = UILabel()
    private let hashTagCollectionView: UICollectionView = {
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let memberLabel = UILabel()
    private let memberCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let informationLabel = UILabel()
    private let restaurantView = AppointmentDetailInfoView(type: .restaurant, fromSearch: true)
    private let menuView = AppointmentDetailInfoView(type: .menu, fromSearch: true)
    private let timeView = AppointmentDetailInfoView(type: .time, fromSearch: true)
    private let remainTimeView = AppointmentDetailInfoView(type: .remainTime, fromSearch: true)
    private let distanceView = AppointmentDetailInfoView(type: .distance, fromSearch: true)
    private let participantButton = LunchatButton()
    
    private let viewModel: AppointmentDetailViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: AppointmentDetailViewModel) {
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
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setConfig() {
        containerView.backgroundColor = AppColor.white.color
        mapView.showLocationButton = true
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 26)
        titleLabel.textColor = AppColor.black.color
        titleLabel.text = "런챗"
        
        hashTagCollectionView.backgroundColor = AppColor.white.color
        hashTagCollectionView.register(HashTagCollectionViewCell.self, forCellWithReuseIdentifier: HashTagCollectionViewCell.identifier)
        hashTagCollectionView.delegate = self
        hashTagCollectionView.isScrollEnabled = false
        
        memberLabel.font = AppFont.shared.getBoldFont(size: 19)
        memberLabel.textColor = AppColor.black.color
        memberLabel.text = "밥약 멤버"
        
        memberCollectionView.backgroundColor = AppColor.white.color
        memberCollectionView.isScrollEnabled = false
        memberCollectionView.delegate = self
        memberCollectionView.register(MemberCollectionViewCell.self, forCellWithReuseIdentifier: MemberCollectionViewCell.identifier)
        
        informationLabel.font = AppFont.shared.getBoldFont(size: 19)
        informationLabel.textColor = AppColor.black.color
        informationLabel.text = "밥약 정보"
        
        participantButton.setTitle("참가하기", for: .normal)
        participantButton.setFont(of: 16)
    }
    
    private func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(mapView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(hashTagCollectionView)
        containerView.addSubview(memberLabel)
        containerView.addSubview(memberCollectionView)
        containerView.addSubview(informationLabel)
        containerView.addSubview(restaurantView)
        containerView.addSubview(menuView)
        containerView.addSubview(timeView)
        containerView.addSubview(remainTimeView)
        containerView.addSubview(distanceView)
        containerView.addSubview(participantButton)
    }
    
    private func setConstraint() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(self.scrollView)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(16)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        hashTagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.height.equalTo(28)
            make.width.equalToSuperview().offset(-32)
            make.leading.equalTo(16)
        }
        
        memberLabel.snp.makeConstraints { make in
            make.top.equalTo(hashTagCollectionView.snp.bottom).offset(32)
            make.leading.equalTo(16)
        }
        
        memberCollectionView.snp.makeConstraints { make in
            make.top.equalTo(memberLabel.snp.bottom).offset(24)
            make.height.equalTo(127)
            make.width.equalToSuperview().offset(-32)
            make.leading.equalTo(16)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(memberCollectionView.snp.bottom).offset(32)
            make.leading.equalTo(16)
        }
        
        restaurantView.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(24)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        menuView.snp.makeConstraints { make in
            make.top.equalTo(restaurantView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        timeView.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        remainTimeView.snp.makeConstraints { make in
            make.top.equalTo(timeView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        distanceView.snp.makeConstraints { make in
            make.top.equalTo(remainTimeView.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        participantButton.snp.makeConstraints { make in
            make.top.equalTo(distanceView.snp.bottom).offset(32)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        let input = AppointmentDetailViewModel.Input(
            participantSign: participantButton.rx.tap.asSignal())
        let output = viewModel.transform(input: input)
        
        output.appointment.subscribe({ [weak self] info in
            guard let self = self else { return }
            
            if let info = info.element {
                self.titleLabel.text = info.title
                self.memberLabel.text = "밥약 멤버(\(info.currParticipants)/\(info.maxParticipants))"
                self.restaurantView.setTitle(title: info.placeTitle)
                self.restaurantView.setInfoText(text: info.placeRoadAddress)
                
                if let menu = MenuType.allCases.filter({ $0.rawValue.uppercased() == info.menu }).first?.title {
                    self.menuView.setInfoText(text: menu)
                } else {
                    self.menuView.setInfoText(text: "알 수 없음")
                }
                self.timeView.setInfoText(text: info.scheduledAt)
                self.remainTimeView.setInfoText(text: "\(info.remainingTime)시간")
                self.distanceView.setInfoText(text: "\(Int(info.distance))km")
 
                let cameraPosition = NMFCameraPosition(NMGLatLng(lat: Double(info.placeLatitude)!, lng: Double(info.placeLongitude)!), zoom: 16)
                let updatedPosition = NMFCameraUpdate(position: cameraPosition)
                let markerPosition = NMGLatLng(lat: Double(info.placeLatitude)!, lng: Double(info.placeLongitude)!)
                let marker = NMFMarker(position: markerPosition, iconImage: NMFOverlayImage(image: UIImage(named: "locationMarker")!))
                
                self.mapView.mapView.moveCamera(updatedPosition)
                marker.mapView = self.mapView.mapView
            }
        })
        .disposed(by: disposeBag)
        
        output.members.bind(to: self.memberCollectionView.rx.items(cellIdentifier: MemberCollectionViewCell.identifier, cellType: MemberCollectionViewCell.self)) { [weak self] (index, item, cell) in
            if index == 0 {
                cell.setIsLeader(isLeader: true)
            } else {
                cell.setIsLeader(isLeader: false)
            }
            cell.setDataSource(memberInfo: item)
            
            UIView.performWithoutAnimation {
                self?.hashTagCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
        .disposed(by: disposeBag)
        
        output.hashtags.bind(to: self.hashTagCollectionView.rx.items(cellIdentifier: HashTagCollectionViewCell.identifier, cellType: HashTagCollectionViewCell.self)) { [weak self] (index, item, cell) in
            cell.setDataSource(hashtag: item)
            self?.hashTagCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
        .disposed(by: disposeBag)
        
        output.isActive.subscribe({ [weak self] isActive in
            if let isActive = isActive.element, isActive {
                self?.participantButton.setActive()
                self?.participantButton.isEnabled = true
            } else {
                self?.participantButton.setInActive()
                self?.participantButton.isEnabled = false
            }
        })
        .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
extension AppointmentDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.memberCollectionView {
            let width: CGFloat = self.memberCollectionView.frame.width / 4 - 8
            return CGSize(width: width, height: collectionView.bounds.height)
        } else {
            let width: CGFloat = (self.hashTagCollectionView.cellForItem(at: indexPath) as? HashTagCollectionViewCell)?.getIntrinsicWidth() ?? 50
            return CGSize(width: width, height: collectionView.bounds.height)
        }
    }
}
