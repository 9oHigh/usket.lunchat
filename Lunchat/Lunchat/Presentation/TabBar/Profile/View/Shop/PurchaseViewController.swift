//
//  PurchaseViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import UIKit
import RxSwift
import RxCocoa

final class PurchaseViewController: BaseViewController {
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumLineSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    private let ticketInformationView = TicketInformationView()
    
    private let viewModel: PurchaseViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: PurchaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setConfig()
        setUI()
        setConstraint()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoadingView), name: NSNotification.Name.removeLoadingView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addLoadingView), name: NSNotification.Name.addLoadingView, object: nil)
    }
    
    private func bind() {
        let input = PurchaseViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.ticketCount
            .subscribe({ [weak self] ticketCount in
                if let ticketCount = ticketCount.element {
                    let notification = Foundation.Notification(name: Foundation.Notification.Name.ticketCount, object: nil, userInfo: ["message": ticketCount])
                    NotificationCenter.default.post(notification)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PurchaseCollectionViewCell.self, forCellWithReuseIdentifier: PurchaseCollectionViewCell.identifier)
        collectionView.register(TicketInformationView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TicketInformationView.identifier)
        collectionView.backgroundColor = AppColor.white.color
    }
    
    private func setUI() {
        view.addSubview(collectionView)
        view.addSubview(ticketInformationView)
    }
    
    private func setConstraint() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(60)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.bounds.height * (bottomInset > 20 ? 0.39 : 0.375))
        }
        
        ticketInformationView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func removeLoadingView() {
        self.hideLoadingView(0)
    }
    
    @objc
    private func addLoadingView() {
        self.showLoadingView(true)
    }
    
    deinit {
        disposeBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}
extension PurchaseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PurchaseCollectionViewCell.identifier, for: indexPath) as? PurchaseCollectionViewCell,
              let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        else {
            return UICollectionViewCell()
        }
        
        let ticket = TicketType.allCases[indexPath.row]
        
        if bottomInset < 20 {
            cell.setDataSource(ticketCount: String(ticket.rawValue), cost: ticket.price, isNotch: false)
        } else {
            cell.setDataSource(ticketCount: String(ticket.rawValue), cost: ticket.price, isNotch: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let bottomInset =  UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        else {
            return CGSize(width: 107, height: 144)
        }
        
        let collectionViewWidth = collectionView.bounds.width
        let spacing: CGFloat = 8.0
        let margin: CGFloat = 16.0
        
        let totalSpacing = spacing * 2
        let totalMargin = margin * 2
        
        let itemWidth = (collectionViewWidth - totalSpacing - totalMargin) / 3
        var itemHeight = itemWidth * 1.34
        
        if bottomInset < 20 {
            itemHeight = itemWidth
        }
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ticket = TicketType.allCases[indexPath.row]
        viewModel.showNoteTicketCreate(ticket: ticket)
    }
}

extension PurchaseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
