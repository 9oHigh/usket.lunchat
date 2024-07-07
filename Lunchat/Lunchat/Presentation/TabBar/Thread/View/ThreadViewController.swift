//
//  ThreadViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/18.
//

import UIKit
import RxSwift

final class ThreadViewController: BaseViewController {
    
    private let threadHeaderView = ThreadHeaderView()
    private let notificationHeaderView = UIView()
    private let threadTableView = UITableView()
    private let newThreadButton = UIButton()
    private let refreshControl = UIRefreshControl()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    private let emptyView = EmptyView(type: .thread)
    
    private let viewModel: ThreadViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: ThreadViewModel) {
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

        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadPostsNotification), name: NSNotification.Name.reloadPosts, object: nil)
    }
    
    @objc
    private func handleReloadPostsNotification() {
        self.viewModel.setDefaultPageOptions()
        self.viewModel.getPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        viewModel.getUserInfo()
        if !emptyView.isHidden {
            viewModel.setDefaultPageOptions()
            viewModel.getPosts()
        }
    }
    
    private func setConfig() {
        emptyView.isHidden = true
        
        threadTableView.refreshControl = refreshControl
        threadTableView.tableFooterView = bottomIndicatorView
        threadTableView.separatorStyle = .none
        threadTableView.showsHorizontalScrollIndicator = false
        threadTableView.rowHeight = 100
        threadTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        threadTableView.backgroundColor = AppColor.white.color
        threadTableView.register(ThreadTableViewCell.self, forCellReuseIdentifier: ThreadTableViewCell.identifier)
        
        newThreadButton.setImage(UIImage(named: "new_thread"), for: .normal)
    }
    
    private func setUI() {
        view.addSubview(threadHeaderView)
        view.addSubview(threadTableView)
        view.addSubview(newThreadButton)
        view.addSubview(emptyView)
        view.bringSubviewToFront(newThreadButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        threadHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.0955).offset(inset > 20 ? inset/2 : 8)
            make.leading.trailing.equalToSuperview()
        }
        
        threadTableView.snp.makeConstraints { make in
            make.top.equalTo(threadHeaderView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(threadHeaderView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        newThreadButton.snp.makeConstraints { make in
            make.trailing.equalTo(-12)
            make.width.equalTo(124)
            make.height.equalTo(inset > 20 ? 52 : 44)
            make.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0) - 20)
        }
    }
    
    private func bind() {
        let input = ThreadViewModel.Input(toNotificationSignal: threadHeaderView.getNotificationButtonObservable().asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input: input)
        
        output.posts
            .distinctUntilChanged({ prev, current in
                self.refreshControl.endRefreshing()
                self.hideLoadingView()
                return false
            })
            .bind(to: threadTableView.rx.items(cellIdentifier: ThreadTableViewCell.identifier, cellType: ThreadTableViewCell.self)) { (index, item, cell) in
                cell.setDataSource(post: item)
            }
            .disposed(by: disposeBag)
        
        output.posts
            .subscribe(onNext: { [weak self] posts in
                if posts.isEmpty {
                    self?.threadTableView.isHidden = true
                    self?.emptyView.isHidden = false
                } else {
                    self?.threadTableView.isHidden = false
                    self?.emptyView.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        output.userInfo.subscribe({ [weak self] info in
            if let userInfo = info.element {
                self?.threadHeaderView.setDataSource(userInfo)
            }
        })
        .disposed(by: disposeBag)
        
        threadHeaderView.getMyPostButtonObservable().subscribe({ [weak self] _ in
            self?.viewModel.showMyThreadViewController()
        })
        .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        threadTableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.threadTableView.contentOffset.y
                let contentHeight = self.threadTableView.contentSize.height
                let scrollViewHeight = self.threadTableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != 0 {
                    self.viewModel.getMorePosts()
                }
            }).disposed(by: disposeBag)
        
        threadTableView.rx.itemSelected.subscribe({ [weak self] indexPath in
            guard let indexPath = indexPath.element else { return }
            
            let cell = self?.threadTableView.cellForRow(at: indexPath) as? ThreadTableViewCell
            
            if let id = cell?.getId() {
                self?.viewModel.showThreadDetail(id: id)
            }
        })
        .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.getPosts()
                self?.threadTableView.isHidden = false
                self?.emptyView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        threadTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        newThreadButton.rx.tap
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe({ _ in
                self.viewModel.moveToCreateThreadCoordinator()
            })
            .disposed(by: disposeBag)
    }
}

extension ThreadViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
