//
//  SearchAppointmentViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/15.
//

import UIKit
import RxSwift

final class SearchAppointmentViewController: BaseViewController, UICollectionViewDelegate {
    
    private lazy var appointmentCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 12
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    private let refreshControl = UIRefreshControl()
    private let noResultView = NoResultView()
    private let bottomIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private let viewModel: SearchAppointmentViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: SearchAppointmentViewModel) {
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
        viewModel.getAppointment()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.searchAppointment, object: nil, queue: .main) { [weak self] noti in
            self?.showLoadingView()
            if let searchedText = noti.userInfo?["message"] as? String {
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.setKeyword(text: searchedText)
                self?.viewModel.getAppointment(keyword: searchedText)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.searchAppointmentRefresh, object: nil, queue: .main) { [weak self] _ in
            self?.viewModel.setDefaultPageOptions()
            self?.viewModel.getAppointment()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !noResultView.isHidden {
            viewModel.setDefaultPageOptions()
            viewModel.getAppointment()
        }
    }
    
    private func setConfig() {
        noResultView.isHidden = true
        appointmentCollectionView.delegate = self
        appointmentCollectionView.backgroundColor = AppColor.white.color
        appointmentCollectionView.register(SearchAppointmentCollectionViewCell.self, forCellWithReuseIdentifier: SearchAppointmentCollectionViewCell.identifier)
        appointmentCollectionView.refreshControl = refreshControl
    }
    
    private func setUI() {
        view.addSubview(noResultView)
        view.addSubview(appointmentCollectionView)
        appointmentCollectionView.addSubview(bottomIndicatorView)
    }
    
    private func setConstraint() {
        noResultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        appointmentCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(appointmentCollectionView.snp.bottom)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        let input = SearchAppointmentViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.appointments
            .flatMapLatest { appointments -> Observable<[Appointment]> in
                self.refreshControl.endRefreshing()
                let filtered = appointments.filter { $0 != .empty }
                self.hideLoadingView(0.8)
                return Observable.just(filtered)
            }
            .bind(to: self.appointmentCollectionView.rx.items(cellIdentifier: SearchAppointmentCollectionViewCell.identifier, cellType: SearchAppointmentCollectionViewCell.self)) { (index, item, cell) in
                cell.setDataSource(appointment: item)
            }
            .disposed(by: disposeBag)
        
        output.appointments
            .map { $0.isEmpty }
            .bind(to: appointmentCollectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.appointments
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
        
        appointmentCollectionView.rx.didScroll
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.appointmentCollectionView.contentOffset.y
                let contentHeight = self.appointmentCollectionView.contentSize.height
                let scrollViewHeight = self.appointmentCollectionView.frame.height
                if (offsetY > contentHeight - scrollViewHeight) && offsetY != 0  {
                    self.viewModel.getMoreAppointments()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name.hideKeyboard, object: nil)
            }).disposed(by: disposeBag)
        
        appointmentCollectionView.rx.itemSelected.subscribe({ [weak self] indexPath in
            guard let indexPath = indexPath.element else { return }
            
            let cell = self?.appointmentCollectionView.cellForItem(at: indexPath) as? SearchAppointmentCollectionViewCell
            
            if let appointmentId = cell?.getAppointmentId() {
                self?.viewModel.showAppointmentDetailView(id: appointmentId)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.hideKeyboard, object: nil)
        })
        .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.setDefaultPageOptions()
                self?.viewModel.getAppointment()
                self?.noResultView.isHidden = true
                self?.appointmentCollectionView.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchAppointmentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 3 * 14) / 2
        let divided = UserDefaults.standard.getSafeAreaInset()
        return CGSize(width: width, height: collectionView.bounds.height / (divided > 20 ? 4 : 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
}
