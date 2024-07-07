//
//  ShopViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import UIKit
import Tabman
import Pageboy

final class ShopViewController: TabmanViewController {
    
    private let ticketView = UIView()
    private let ticketImageView = UIImageView(image: UIImage(named: "ticket"))
    private let ticketTitleLabel = UILabel()
    private let ticketCountlabel = UILabel()
    private let bar = TMBar.ButtonBar()
    private var viewControllers: [UIViewController] = []
    
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
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
     
    private func setConfig() {
        view.backgroundColor = AppColor.white.color
        
        ticketView.backgroundColor = AppColor.textField.color
        
        ticketTitleLabel.text = "현재 보유한 쪽지"
        ticketTitleLabel.textColor = AppColor.deepGrayText.color
        ticketTitleLabel.font = AppFont.shared.getBoldFont(size: 15)
        
        ticketCountlabel.text = "0개"
        ticketCountlabel.textColor = AppColor.purple.color
        ticketCountlabel.font = AppFont.shared.getBoldFont(size: 15)
        
        dataSource = self
        
        bar.layout.transitionStyle = .snap
        bar.backgroundView.style = .flat(color: .white)
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        bar.indicator.tintColor = AppColor.black.color
        bar.tintColor = AppColor.black.color
        bar.buttons.customize { button in
            button.selectedTintColor = AppColor.black.color
            button.tintColor = AppColor.grayText.color
            button.font = AppFont.shared.getBoldFont(size: 20)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ticketCount, object: nil, queue: .main) { [weak self] noti in
            if let count = noti.userInfo?["message"] as? String {
                self?.ticketCountlabel.text = "\(count)개"
            }
        }
    }
    
    private func setUI() {
        view.addSubview(ticketView)
        ticketView.addSubview(ticketImageView)
        ticketView.addSubview(ticketTitleLabel)
        ticketView.addSubview(ticketCountlabel)
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func setConstraint() {
        ticketView.snp.makeConstraints { make in
            make.top.equalTo(bar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        ticketImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalTo(14)
        }
        
        ticketTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(ticketImageView.snp.trailing).offset(8)
        }
        
        ticketCountlabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(ticketTitleLabel.snp.trailing).offset(16)
        }
    }
    
    private func setViewControllers(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ShopViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
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
        
        var title: String = ""
        
        switch index {
        case 0: title = "쪽지구매"
        case 1: title = "구매내역"
        case 2: title = "사용내역"
        default: break
        }
        
        return TMBarItem(title: title)
    }
}
