//
//  SharedThreadViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/25.
//

import UIKit
import RxSwift

final class SharedThreadViewController: BaseViewController, UIScrollViewDelegate {
    
    private let noThreadView = NoThreadView(type: .shared)
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private let viewModel: MyThreadViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: MyThreadViewModel) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPosts), name: NSNotification.Name.reloadSharedPosts, object: nil)
    }
    
    @objc
    private func reloadPosts() {
        self.viewModel.setDefaultPageOptions()
        self.viewModel.fetchSharedPosts()
    }
    
    private func setConfig() {
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = bottomIndicatorView
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = AppColor.white.color
        tableView.register(ThreadTableViewCell.self, forCellReuseIdentifier: ThreadTableViewCell.identifier)
        
        noThreadView.isHidden = true
    }
    
    private func setUI() {
        view.addSubview(noThreadView)
        view.addSubview(tableView)
    }
    
    private func setConstraint() {
        noThreadView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        viewModel.subscribeShared()
        viewModel.fetchSharedPosts()
        
        viewModel.sharedPosts
            .distinctUntilChanged({ prev, current in
                self.refreshControl.endRefreshing()
                self.hideLoadingView()
                return false
            })
            .bind(to: tableView.rx.items(cellIdentifier: ThreadTableViewCell.identifier, cellType: ThreadTableViewCell.self)) { (index, item, cell) in
            cell.setDataSource(post: item)
        }
        .disposed(by: disposeBag)
        
        viewModel.sharedPosts
            .skip(1)
            .map { $0.isEmpty }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.sharedPosts
            .skip(1)
            .map { !$0.isEmpty }
            .bind(to: noThreadView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != -16 {
                    self.viewModel.getMoreSharedPosts()
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe({ [weak self] indexPath in
            guard let indexPath = indexPath.element else { return }
            
            let cell = self?.tableView.cellForRow(at: indexPath) as? ThreadTableViewCell
            
            if let id = cell?.getId() {
                self?.viewModel.showSharedThreadDetailView(id: id)
            }
        })
        .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.fetchSharedPosts()
                self?.tableView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        noThreadView.getNewThreadButtonObservable()
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe({ _ in
                self.viewModel.moveToCreateThread()
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        disposeBag = DisposeBag()
    }
}
