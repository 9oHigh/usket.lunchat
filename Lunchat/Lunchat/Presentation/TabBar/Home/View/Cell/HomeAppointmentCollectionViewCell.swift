//
//  HomeCollectionViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/09.
//

import UIKit
import RxSwift
import RxCocoa
import NMapsMap

final class HomeAppointmentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeAppointmentCollectionViewCell"
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
        flowLayout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let informationLabel = UILabel()
    private let restaurantView = AppointmentDetailInfoView(type: .restaurant)
    private let menuView = AppointmentDetailInfoView(type: .menu)
    private let timeView = AppointmentDetailInfoView(type: .time)
    private let remainTimeView = AppointmentDetailInfoView(type: .remainTime)
    private let distanceView = AppointmentDetailInfoView(type: .distance)
    private let participantButton = LunchatButton()
    
    private var viewModel: HomeAppointmentCellViewModel?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.memberLabel.text = nil
        self.restaurantView.setTitle(title: "")
        self.restaurantView.setInfoText(text: "")
        
        self.menuView.setInfoText(text: "")
        self.timeView.setInfoText(text: "")
        self.remainTimeView.setInfoText(text: "")
        self.distanceView.setInfoText(text: "")
        
        self.disposeBag = DisposeBag()
        self.participantButton.setInActive()
        self.participantButton.isEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = AppColor.white.color
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    func setDataSource(appointment: Appointment, viewModel: HomeAppointmentCellViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = appointment.title
        self.memberLabel.text = "밥약 멤버(\(appointment.currParticipants)/\(appointment.maxParticipants))"
        self.restaurantView.setTitle(title: appointment.placeTitle)
        self.restaurantView.setInfoText(text: appointment.placeRoadAddress)
        
        var menu: String
        switch appointment.menu {
        case "KOREAN":
            menu = "한식"
        case "JAPANESE":
            menu = "일식"
        case "CHINESE":
            menu = "중식"
        default:
            menu = "양식"
        }
        
        self.menuView.setInfoText(text: menu)
        self.timeView.setInfoText(text: appointment.scheduledAt)
        self.remainTimeView.setInfoText(text: "\(appointment.remainingTime)시간")
        self.distanceView.setInfoText(text: "\(Int(appointment.distance))km")
        
        let cameraPosition = NMFCameraPosition(NMGLatLng(lat: Double(appointment.placeLatitude)!, lng: Double(appointment.placeLongitude)!), zoom: 16)
        let updatedPosition = NMFCameraUpdate(position: cameraPosition)
        let markerPosition = NMGLatLng(lat: Double(appointment.placeLatitude)!, lng: Double(appointment.placeLongitude)!)
        let marker = NMFMarker(position: markerPosition, iconImage: NMFOverlayImage(image: UIImage(named: "locationMarker")!))
        
        self.mapView.mapView.moveCamera(updatedPosition)
        marker.mapView = self.mapView.mapView
        
        let tags: Observable<[String]> = Observable.just(appointment.hashTags ?? [])
        let members: Observable<[Participant]> = Observable.just(appointment.participants)
        
        tags
            .bind(to: self.hashTagCollectionView.rx.items(cellIdentifier: HashTagCollectionViewCell.identifier, cellType: HashTagCollectionViewCell.self)) { [weak self] (index, item, cell) in
            cell.setDataSource(hashtag: item)
            UIView.performWithoutAnimation {
                self?.hashTagCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
        .disposed(by: disposeBag)
        
        if let hashTags = appointment.hashTags, !hashTags.isEmpty {
            hashTagCollectionView.isHidden = false
        } else {
            hashTagCollectionView.isHidden = true
        }
        
        members
            .withUnretained(self)
            .map { owner, input in
                var newParticipants: [Participant?] = input
                while newParticipants.count < appointment.maxParticipants {
                    newParticipants.append(nil)
                }
                
                return newParticipants.sorted { (participant1, participant2) -> Bool in
                    if let p1 = participant1, let p2 = participant2 {
                        return p1.nickname == appointment.organizerNickname && p2.nickname != appointment.organizerNickname
                    } else if let p1 = participant1 {
                        return p1.nickname == appointment.organizerNickname
                    } else {
                        return false
                    }
                }
            }
            .bind(to: self.memberCollectionView.rx.items(cellIdentifier: MemberCollectionViewCell.identifier, cellType: MemberCollectionViewCell.self)) { [weak self] (index, item, cell) in
                if item?.nickname == appointment.organizerNickname {
                    cell.setIsLeader(isLeader: true)
                } else {
                    cell.setIsLeader(isLeader: false)
                }
                cell.setDataSource(memberInfo: item)
            }
            .disposed(by: disposeBag)
        
        let status = UserStatusTracker.shared.getUserStatus()
        
        if status == .made {
            self.participantButton.setImage(UIImage(named: HomeCellButtonType.cancel.imageName), for: .normal)
            self.participantButton.setActive()
            self.participantButton.isEnabled = true
            
            self.participantButton.rx.tap.subscribe({ _ in
                self.viewModel?.showLeavAppointment()
            })
            .disposed(by: disposeBag)
        } else if status == .participated {
            self.participantButton.setImage(UIImage(named: HomeCellButtonType.exit.imageName), for: .normal)
            self.participantButton.setActive()
            self.participantButton.isEnabled = true
            
            self.participantButton.rx.tap.subscribe({ [weak self] _ in
                self?.viewModel?.showLeavAppointment()
            })
            .disposed(by: disposeBag)
        } else {
            self.participantButton.setImage(UIImage(named: HomeCellButtonType.participate.imageName), for: .normal)
            if appointment.participants.count == appointment.maxParticipants {
                self.participantButton.setInActive()
                self.participantButton.isEnabled = false
            } else {
                self.participantButton.setActive()
                self.participantButton.isEnabled = true
            }
            
            self.participantButton.rx.tap.subscribe({ [weak self] _ in
                self?.viewModel?.showJoinAppointment(id: appointment.id)
            })
            .disposed(by: disposeBag)
        }
        
        setConstraint()
    }
    
    private func setConfig() {
        mapView.mapView.positionMode = .compass
        mapView.showLocationButton = false
        mapView.showZoomControls = false
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        titleLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 24 : 18)
        titleLabel.textColor = AppColor.black.color
        titleLabel.text = "런챗"
        
        hashTagCollectionView.backgroundColor = AppColor.white.color
        hashTagCollectionView.register(HashTagCollectionViewCell.self, forCellWithReuseIdentifier: HashTagCollectionViewCell.identifier)
        hashTagCollectionView.delegate = self
        hashTagCollectionView.isScrollEnabled = false
        
        memberLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 13 : 11)
        memberLabel.textColor = AppColor.black.color
        memberLabel.text = "밥약 멤버"
        
        memberCollectionView.backgroundColor = AppColor.white.color
        memberCollectionView.isScrollEnabled = false
        memberCollectionView.delegate = self
        memberCollectionView.register(MemberCollectionViewCell.self, forCellWithReuseIdentifier: MemberCollectionViewCell.identifier)
        
        informationLabel.font = AppFont.shared.getBoldFont(size: inset > 20 ? 13 : 11)
        informationLabel.textColor = AppColor.black.color
        informationLabel.text = "밥약 정보"
        
        participantButton.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        contentView.addSubview(mapView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(hashTagCollectionView)
        contentView.addSubview(memberLabel)
        contentView.addSubview(memberCollectionView)
        contentView.addSubview(informationLabel)
        contentView.addSubview(restaurantView)
        contentView.addSubview(menuView)
        contentView.addSubview(timeView)
        contentView.addSubview(remainTimeView)
        contentView.addSubview(distanceView)
        contentView.addSubview(participantButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        mapView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        titleLabel.snp.remakeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(8)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(titleLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .greatestFiniteMagnitude)).height)
        }
        
        if !hashTagCollectionView.isHidden {
            hashTagCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.height.equalTo(14)
                make.leading.equalTo(16)
                make.trailing.equalTo(-16)
            }
            
            memberLabel.snp.remakeConstraints { make in
                make.top.equalTo(hashTagCollectionView.snp.bottom).offset(4)
                make.leading.equalTo(16)
                make.trailing.equalTo(-16)
                make.height.equalTo(titleLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .greatestFiniteMagnitude)).height)
            }
        } else {
            memberLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.leading.equalTo(16)
                make.trailing.equalTo(-16)
                make.height.equalTo(titleLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .greatestFiniteMagnitude)).height)
            }
        }
        
        memberCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(memberLabel.snp.bottom).offset(4)
            make.height.equalToSuperview().multipliedBy(0.2)
            make.width.equalToSuperview().offset(-32)
            make.leading.equalTo(16)
        }
        
        informationLabel.snp.remakeConstraints { make in
            make.top.equalTo(memberCollectionView.snp.bottom)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(titleLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .greatestFiniteMagnitude)).height)
        }
        
        restaurantView.snp.remakeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(6)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(24)
        }
        
        menuView.snp.remakeConstraints { make in
            make.top.equalTo(restaurantView.snp.bottom).offset(6)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(24)
        }
        
        timeView.snp.remakeConstraints { make in
            make.top.equalTo(menuView.snp.bottom).offset(6)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(24)
        }
        
        remainTimeView.snp.remakeConstraints { make in
            make.top.equalTo(timeView.snp.bottom).offset(6)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(24)
        }
        
        distanceView.snp.remakeConstraints { make in
            make.top.equalTo(remainTimeView.snp.bottom).offset(6)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(24)
        }
        
        participantButton.snp.remakeConstraints { make in
            make.height.equalTo(inset > 20 ? 40 : 30)
            make.leading.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
extension HomeAppointmentCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.memberCollectionView {
            let width: CGFloat = self.memberCollectionView.frame.width / 4 - 12
            return CGSize(width: width, height: collectionView.bounds.height)
        } else {
            let width: CGFloat = (self.hashTagCollectionView.cellForItem(at: indexPath) as? HashTagCollectionViewCell)?.getIntrinsicWidth() ?? 50
            return CGSize(width: width, height: collectionView.bounds.height)
        }
    }
}
