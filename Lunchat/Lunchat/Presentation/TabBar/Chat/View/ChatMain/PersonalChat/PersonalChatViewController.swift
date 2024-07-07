//
//  PersonalChatViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/14.
//

import UIKit
import RxSwift

final class PersonalChatViewController: BaseViewController {
    
    private let refreshControl = UIRefreshControl()
    private let noMessageView = NoChatRoomView(type: .message)
    private let chatTableView = UITableView()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private var viewModel: PersonalChatViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: PersonalChatViewModel) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setDefaultPageOptions()
        viewModel.getChatRooms()
    }
    
    private func setConfig() {
        chatTableView.refreshControl = refreshControl
        chatTableView.backgroundColor = AppColor.white.color
        chatTableView.rowHeight = 100
        chatTableView.showsHorizontalScrollIndicator = false
        chatTableView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        chatTableView.separatorStyle = .none
        chatTableView.tableFooterView = bottomIndicatorView
        chatTableView.register(PersonalChatCell.self, forCellReuseIdentifier: PersonalChatCell.identifier)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = UISwipeGestureRecognizer.Direction.left
        swipeGesture.delegate = self
        chatTableView.addGestureRecognizer(swipeGesture)
        
        noMessageView.isHidden = true
    }
    
    private func setUI() {
        view.addSubview(chatTableView)
        view.addSubview(noMessageView)
    }
    
    private func setConstraint() {
        chatTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        noMessageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = PersonalChatViewModel.Input()
        let output = viewModel.transform(input: input)
        
        chatTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        output.chatRooms
            .throttle(.seconds(2), latest: true, scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged({ prev, current in
                self.refreshControl.endRefreshing()
                self.hideLoadingView(1)
                return false
            })
            .bind(to: chatTableView.rx.items(cellIdentifier: PersonalChatCell.identifier, cellType: PersonalChatCell.self)) { [weak self] (index, item, cell) in
                cell.setDataSource(chatRoom: item)
            }
            .disposed(by: disposeBag)
        
        output.chatRooms
            .map { $0.isEmpty }
            .bind(to: chatTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.chatRooms
            .map { !$0.isEmpty }
            .bind(to: noMessageView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        chatTableView.rx.itemSelected.subscribe({ [weak self] indexPath in
            guard let indexPath = indexPath.element else { return }
            
            let cell = self?.chatTableView.cellForRow(at: indexPath) as? PersonalChatCell
            if let chatRoom = cell?.getDataSource() {
                self?.viewModel.showPersonalChatViewController(chatRoom: chatRoom)
            }
        })
        .disposed(by: disposeBag)
        
        chatTableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.chatTableView.contentOffset.y
                let contentHeight = self.chatTableView.contentSize.height
                let scrollViewHeight = self.chatTableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY >= 0 {
                    self.viewModel.getMoreChatRooms()
                }
            }).disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.getChatRooms()
                self?.noMessageView.isHidden = true
                self?.chatTableView.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            NotificationCenter.default.post(name: NSNotification.Name.chatRightGesture, object: nil)
        }
    }
}

extension PersonalChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

extension PersonalChatViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
