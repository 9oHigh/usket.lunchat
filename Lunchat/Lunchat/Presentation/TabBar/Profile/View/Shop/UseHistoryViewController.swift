//
//  UseHistoryViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import UIKit
import RxSwift
import RxCocoa

final class UseHistoryViewController: BaseViewController, UIScrollViewDelegate {
  
    private let tableView = UITableView()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    private let emptyView = EmptyView(type: .use)
    
    private let viewModel: UseHistoryViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: UseHistoryViewModel) {
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
        viewModel.getUseHistories()
    }
    
    private func bind() {
        let input = UseHistoryViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.histories
            .bind(to: tableView.rx.items(cellIdentifier: UseHistoryCell.identifier, cellType: UseHistoryCell.self)) { [weak self] (row, element, cell) in
                cell.setDataSource(date: element.usedAt, toUserNickname: element.toUserNickname, toUserProfileURL: element.toUserProfilePicture)
        }
        .disposed(by: disposeBag)
        
        output.histories
            .subscribe(onNext: { [weak self] histories in
                if histories.isEmpty {
                    self?.tableView.isHidden = true
                    self?.emptyView.isHidden = false
                } else {
                    self?.tableView.isHidden = false
                    self?.emptyView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != 0 {
                    self.viewModel.getMoreUseHistories()
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: bottomIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: bottomIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setConfig() {
        emptyView.isHidden = true
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.register(UseHistoryCell.self, forCellReuseIdentifier: UseHistoryCell.identifier)

        tableView.tableFooterView = bottomIndicatorView
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setUI() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
    }
    
    private func setConstraint() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(44)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(44)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
