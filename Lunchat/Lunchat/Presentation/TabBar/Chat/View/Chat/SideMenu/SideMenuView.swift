//
//  SideMenuViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/07.
//

import UIKit
import RxSwift

final class SideMenuView: UIView, UIScrollViewDelegate {

    private let photoView = SideMenuPhotoView()
    private let personImageView = UIImageView(image: UIImage(named: "person"))
    private let personLabel = UILabel()
    private let participantTableView = UITableView()
    private let exitView = SideMenuExitView()
    
    private let viewModel: ChatViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    private func setConfig() {
        backgroundColor = AppColor.white.color
        
        personImageView.contentMode = .scaleAspectFit
        personLabel.text = "대화상대"
        personLabel.font = AppFont.shared.getBoldFont(size: 12)
        
        participantTableView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        participantTableView.rowHeight = 48
        participantTableView.separatorStyle = .none
        participantTableView.isScrollEnabled = false
        participantTableView.register(SideMenuProfileCell.self, forCellReuseIdentifier: SideMenuProfileCell.identifier)
    }
    
    private func setUI() {
        addSubview(photoView)
        addSubview(personImageView)
        addSubview(personLabel)
        addSubview(participantTableView)
        addSubview(exitView)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        photoView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalToSuperview().multipliedBy(0.162)
        }
        
        personImageView.snp.makeConstraints { make in
            make.top.equalTo(photoView.snp.bottom).offset(12)
            make.leading.equalTo(12)
            make.width.height.equalTo(20)
        }
        
        personLabel.snp.makeConstraints { make in
            make.centerY.equalTo(personImageView.snp.centerY)
            make.leading.equalTo(personImageView.snp.trailing).offset(4)
        }
        
        participantTableView.snp.makeConstraints { make in
            make.top.equalTo(personImageView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        exitView.snp.makeConstraints { make in
            make.height.equalTo(44 + inset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        participantTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        photoView.getPhotosObservable().skip(1).subscribe({ [weak self] _ in
            NotificationCenter.default.post(name: NSNotification.Name.removeSideMenu, object: nil)
            self?.viewModel.showPhotosViewController()
        })
        .disposed(by: disposeBag)
        
        exitView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.viewModel.exitRoom()
        })
        .disposed(by: disposeBag)

        viewModel.photos
            .distinctUntilChanged { prev, current in
                let prevIds = prev.map { $0.fileID }
                let currentIds = current.map { $0.fileID }
                return prevIds == currentIds
            }
            .subscribe({ [weak self] photos in
            if let photosInfo = photos.element {
                self?.photoView.setDataSource(files: photosInfo)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.participantInfo
            .distinctUntilChanged { prev, current in
                let prevNickname = prev.map { $0.nickname }
                let currentNickname = current.map { $0.nickname }
                let prevBios = prev.map { $0.bio }
                let currentBios = current.map { $0.bio }
                return (prevNickname == currentNickname) && (prevBios == currentBios)
            }
            .bind(to: participantTableView.rx.items(cellIdentifier: SideMenuProfileCell.identifier, cellType: SideMenuProfileCell.self)) { [weak self] (index, item, cell) in
            cell.setDataSource(participant: item)
        }
        .disposed(by: disposeBag)
        
        participantTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            let cell = self?.participantTableView.cellForRow(at: indexPath) as? SideMenuProfileCell
            if let nickname = cell?.getUserNickname() {
                self?.viewModel.showUserProfile(nickname: nickname)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.subscribeSideMenuInfo()
    }
    
    func initSideMenuView() {
        viewModel.fetchRoomInfo()
        participantTableView.reloadData()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
