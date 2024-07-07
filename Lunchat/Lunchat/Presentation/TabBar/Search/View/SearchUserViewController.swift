//
//  SearchUserViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/15.
//

import UIKit
import RxSwift

final class SearchUserViewController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private let noResultView = NoResultView()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private let viewModel: SearchUserViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: SearchUserViewModel) {
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
        
        viewModel.setDefaultPageOptions()
        viewModel.getUsers(nickname: "")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.searchUser, object: nil, queue: .main) { [weak self] noti in
            self?.showLoadingView()
            if let searchedText = noti.userInfo?["message"] as? String {
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.getUsers(nickname: searchedText)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !noResultView.isHidden {
            viewModel.setDefaultPageOptions()
            viewModel.getUsers(nickname: "")
        }
    }
    
    private func setConfig() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        tableView.register(SearchUserTableViewCell.self, forCellReuseIdentifier: SearchUserTableViewCell.identifier)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = bottomIndicatorView
        tableView.rowHeight = 72
        tableView.backgroundColor = AppColor.white.color
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = UISwipeGestureRecognizer.Direction.right
        swipeGesture.delegate = self
        tableView.addGestureRecognizer(swipeGesture)
        noResultView.isHidden = true
    }
    
    private func setUI() {
        view.addSubview(noResultView)
        view.addSubview(tableView)
    }
    
    private func setConstraint() {
        noResultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = SearchUserViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.users
            .flatMapLatest { users -> Observable<[SearchedUser]> in
                self.refreshControl.endRefreshing()
                let filtered = users.filter { $0 != .empty }
                self.hideLoadingView(0.8)
                return Observable.just(filtered)
            }
            .bind(to: self.tableView.rx.items(cellIdentifier: SearchUserTableViewCell.identifier, cellType: SearchUserTableViewCell.self)) { [weak self] (index, item, cell) in
                cell.setDataSource(info: item)
            }
            .disposed(by: disposeBag)
        
        output.users
            .map { $0.isEmpty }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.users
            .skip(2)
            .map { !$0.isEmpty }
            .bind(to: noResultView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != 0 {
                    self.viewModel.getMoreUsers()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name.hideKeyboard, object: nil)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe({ [weak self] indexPath in
            guard let indexPath = indexPath.element else { return }
            
            let cell = self?.tableView.cellForRow(at: indexPath) as? SearchUserTableViewCell
            
            if let nickname = cell?.getNickname() {
                self?.viewModel.showUserProfile(nickname: nickname)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.hideKeyboard, object: nil)
        })
        .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.getUsers(nickname: "")
                self?.noResultView.isHidden = true
                self?.tableView.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            NotificationCenter.default.post(name: NSNotification.Name.searchLeftGesture, object: nil)
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchUserViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

extension SearchUserViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
