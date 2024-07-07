//
//  ChatMainViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/05.
//

import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

final class ChatMainViewController: TabmanViewController {
    
    private let bar = TMBar.ButtonBar()
    private var viewControllers: [UIViewController] = []
    private let disposeBag = DisposeBag()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setConfig() {
        definesPresentationContext = true
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(rightGestureActive), name: NSNotification.Name.chatRightGesture, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftGestureActive), name: NSNotification.Name.chatLeftGesture, object: nil)
    }
    
    private func setUI() {
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func setViewControllers(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    @objc
    private func leftGestureActive() {
        scrollToPage(.first, animated: true)
    }
    
    @objc
    private func rightGestureActive() {
        scrollToPage(.last, animated: true)
    }
}

extension ChatMainViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
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
            return TMBarItem(title: "개인채팅")
        } else {
            return TMBarItem(title: "밥약채팅")
        }
    }
}
