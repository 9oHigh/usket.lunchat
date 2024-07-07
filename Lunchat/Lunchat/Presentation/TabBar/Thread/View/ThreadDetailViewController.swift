//
//  ThreadDetailViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/22.
//

import UIKit
import RxSwift
import RxCocoa
import NMapsMap

final class ThreadDetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let areaLabel = UILabel()
    
    private let titleLabel = UILabel()
    private let detailLocationLabel = UILabel()
    private let mapView = NMFNaverMapView()
    private let contentTextView = UITextView()
    
    private let fileImageView = UIImageView()
    private let locationLabel = UILabel()
    private let timeAgoLabel = UILabel()
    private let likeButton = UIButton(type: .custom)
    private let dislikeButton = UIButton(type: .custom)
    
    private let viewModel: ThreadDetailViewModell
    private var disposeBag = DisposeBag()
    
    init(viewModel: ThreadDetailViewModell, isShared: Bool = false) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        if isShared {
            let deleteButton = UIBarButtonItem(image: UIImage(named: "delete_thread"), style: .plain, target: self, action: #selector(deletePost))
            self.navigationItem.rightBarButtonItem = deleteButton
        }
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
        viewModel.getAPost()
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
        disposeBag = DisposeBag()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    @objc
    private func deletePost() {
        viewModel.showDeleteThread()
    }
    
    private func setConfig() {
        scrollView.backgroundColor = AppColor.white.color
        contentView.backgroundColor = AppColor.white.color
        
        profileImageView.clipsToBounds = true
        
        nameLabel.font = AppFont.shared.getBoldFont(size: 18)
        nameLabel.textColor = AppColor.black.color
        
        areaLabel.font = AppFont.shared.getRegularFont(size: 11)
        areaLabel.textColor = AppColor.grayText.color
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        titleLabel.textColor = AppColor.black.color
        
        detailLocationLabel.font = AppFont.shared.getRegularFont(size: 12)
        detailLocationLabel.textColor = AppColor.grayText.color
        
        mapView.mapView.positionMode = .compass
        mapView.showLocationButton = false
        mapView.showZoomControls = false
        
        contentTextView.font = AppFont.shared.getRegularFont(size: 14)
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        
        fileImageView.clipsToBounds = true
        fileImageView.layer.cornerRadius = 5
        fileImageView.contentMode = .scaleAspectFill
        
        locationLabel.font = AppFont.shared.getRegularFont(size: 10)
        locationLabel.textColor = AppColor.grayText.color
        
        timeAgoLabel.font = AppFont.shared.getRegularFont(size: 10)
        timeAgoLabel.textColor = AppColor.grayText.color
        
        likeButton.imageView?.contentMode = .scaleAspectFill
        dislikeButton.imageView?.contentMode = .scaleAspectFill
    }
    
    private func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(areaLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLocationLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(contentTextView)
        contentView.addSubview(fileImageView)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timeAgoLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(dislikeButton)
    }
    
    private func setConstraint() {
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(12)
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.height.equalTo(nameLabel.font.pointSize + 4)
        }
        
        areaLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.height.equalTo(areaLabel.font.pointSize + 4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(28)
            make.leading.equalTo(12)
            make.height.equalTo(titleLabel.font.pointSize + 4)
        }
        
        detailLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(12)
            make.height.equalTo(detailLocationLabel.font.pointSize + 4)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(detailLocationLabel.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(124)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
        }
        
        locationLabel.snp.remakeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(24)
            make.leading.equalTo(12)
            make.height.equalTo(locationLabel.font.pointSize + 4)
            make.bottom.equalToSuperview()
        }
        
        timeAgoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.leading.equalTo(locationLabel.snp.trailing).offset(6)
            make.height.equalTo(timeAgoLabel.font.pointSize + 4)
        }
        
        likeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalTo(dislikeButton.snp.leading).offset(-18)
            make.width.equalTo(36)
            make.height.equalTo(24)
        }
        
        dislikeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalTo(-12)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
    
    private func remakeContraint(post: Post) {
        
        if let _ = post.fileURL {
            fileImageView.snp.remakeConstraints { make in
                make.top.equalTo(contentTextView.snp.bottom).offset(24)
                make.leading.equalTo(12)
                make.trailing.equalTo(-12)
                make.height.equalTo(fileImageView.snp.width)
            }
            
            locationLabel.snp.remakeConstraints { make in
                make.top.equalTo(fileImageView.snp.bottom).offset(24)
                make.leading.equalTo(12)
                make.height.equalTo(locationLabel.font.pointSize + 4)
                make.bottom.equalToSuperview()
            }
        } else {
            locationLabel.snp.remakeConstraints { make in
                make.top.equalTo(contentTextView.snp.bottom).offset(24)
                make.leading.equalTo(12)
                make.height.equalTo(locationLabel.font.pointSize + 4)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    private func bind() {
        
        viewModel.subscribePost()
        viewModel.subscribeLike()
        viewModel.subscribeDisLike()
        viewModel.subScribeDeletePost()
        
        viewModel.post
            .take(1)
            .subscribe({ [weak self] post in
                guard let self = self else { return }
                if let post = post.element {
                    profileImageView.loadImageFromUrl(url: URL(string: post.author.profilePicture))
                    nameLabel.text = post.author.nickname
                    areaLabel.text = post.author.area
                    
                    titleLabel.text = post.title
                    detailLocationLabel.text = post.placeAddress
                    contentTextView.text = post.content
                    if let fileUrl = post.fileURL {
                        fileImageView.loadImageFromUrl(url: URL(string: fileUrl), isDownSampling: false)
                    }
                    locationLabel.text = post.placeArea
                    timeAgoLabel.text = post.remainTime
                    
                    let cameraPosition = NMFCameraPosition(NMGLatLng(lat: Double(post.placeLatitude)!, lng: Double(post.placeLongitude)!), zoom: 16)
                    let updatedPosition = NMFCameraUpdate(position: cameraPosition)
                    let markerPosition = NMGLatLng(lat: Double(post.placeLatitude)!, lng: Double(post.placeLongitude)!)
                    let marker = NMFMarker(position: markerPosition, iconImage: NMFOverlayImage(image: UIImage(named: "locationMarker")!))
                    
                    self.mapView.mapView.moveCamera(updatedPosition)
                    marker.mapView = self.mapView.mapView
                    
                    var config = UIButton.Configuration.plain()
                    config.image = UIImage(named: post.isLiked ? "like_color" : "like")?.resized(to: CGSize(width: 24, height: 24))
                    
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: AppFont.shared.getRegularFont(size: 14),
                        .foregroundColor: AppColor.grayText.color
                    ]
                    let title = NSAttributedString(string: "\(post.likeCount)", attributes: titleAttributes)
                    
                    config.attributedTitle = AttributedString(title)
                    config.imagePadding = 4
                    config.imagePlacement = .leading
                    
                    self.likeButton.configuration = config
                    
                    if post.isDisliked {
                        self.dislikeButton.setImage(UIImage(named: "dislike_color"), for: .normal)
                    } else {
                        self.dislikeButton.setImage(UIImage(named: "dislike"), for: .normal)
                    }
                    
                    self.remakeContraint(post: post)
                }
            })
            .disposed(by: disposeBag)
        
        likeButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            self.viewModel.setLike() {
                self.viewModel.getAPost()
                NotificationCenter.default.post(name: NSNotification.Name.reloadPosts, object: nil)
            }
        })
        .disposed(by: disposeBag)
        
        dislikeButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            self.viewModel.setDisLike {
                self.viewModel.getAPost()
                NotificationCenter.default.post(name: NSNotification.Name.reloadPosts, object: nil)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.isLike
            .observe(on: MainScheduler.instance)
            .subscribe({ [weak self] isLike in
                guard let self = self else { return }
                if let isLiked = isLike.element?.0, let count = isLike.element?.1 {
                    var config = UIButton.Configuration.plain()
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: AppFont.shared.getRegularFont(size: 14),
                        .foregroundColor: AppColor.grayText.color
                    ]
                    let title = NSAttributedString(string: "\(count)", attributes: titleAttributes)
                    
                    if isLiked {
                        config.image = UIImage(named: "like_color")?.resized(to: CGSize(width: 24, height: 24))
                    } else {
                        config.image = UIImage(named: "like")?.resized(to: CGSize(width: 24, height: 24))
                    }
                    
                    config.attributedTitle = AttributedString(title)
                    config.imagePadding = 4
                    config.imagePlacement = .leading
                    self.likeButton.configuration = config
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.disLike
            .observe(on: MainScheduler.instance)
            .subscribe({ [weak self] dislike in
                guard let self = self else { return }
                if let dislike = dislike.element, dislike {
                    self.dislikeButton.setImage(UIImage(named: "dislike_color"), for: .normal)
                } else {
                    self.dislikeButton.setImage(UIImage(named: "dislike"), for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
}
