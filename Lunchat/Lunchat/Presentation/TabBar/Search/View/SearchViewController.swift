//
//  SearchViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/14.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

final class SearchViewController: TabmanViewController {
    
    private let bar = TMBar.ButtonBar()
    private var viewControllers: [UIViewController] = []
    private let searchBar = UISearchBar()
    private var disposeBag = DisposeBag()
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers: viewControllers)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setConfig() {
        definesPresentationContext = true
        searchBar.placeholder = "내 주변 밥약, 유저 검색"
        searchBar.tintColor = .black
        searchBar.barTintColor = .white
        searchBar.delegate = self
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.setValue("취소", forKey: "cancelButtonText")
        dataSource = self
        
        bar.backgroundView.style = .flat(color: .white)
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        bar.indicator.tintColor = AppColor.black.color
        bar.tintColor = AppColor.black.color
        bar.backgroundColor = .white
        bar.buttons.customize { button in
            button.selectedTintColor = AppColor.black.color
            button.tintColor = AppColor.grayText.color
            button.font = AppFont.shared.getBoldFont(size: 20)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(gestureActive), name: NSNotification.Name.searchLeftGesture, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: NSNotification.Name.hideKeyboard, object: nil)
    }
    
    private func setUI() {
        navigationItem.titleView = searchBar
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func bind() {
        searchBar.rx.searchButtonClicked
            .subscribe({ [weak self] text in
                guard let searchText = self?.searchBar.text
                else { return }
                
                let searchAppointmentNotification = Foundation.Notification(name: Foundation.Notification.Name.searchAppointment, object: nil, userInfo: ["message": searchText])
                NotificationCenter.default.post(searchAppointmentNotification)
                
                let searchUserNotification = Foundation.Notification(name: Foundation.Notification.Name.searchUser, object: nil, userInfo: ["message": searchText])
                NotificationCenter.default.post(searchUserNotification)

                self?.searchBar.showsCancelButton = false
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func setViewControllers(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    @objc
    private func gestureActive() {
        scrollToPage(.first, animated: true)
    }
    
    @objc
    private func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        if index == 0 {
            return TMBarItem(title: "밥약")
        } else {
            return TMBarItem(title: "유저")
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
