//
//  TabBarCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit

final class TabBarCoordinator: NSObject, Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var tabBarController: UITabBarController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .tab
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        configureTabbar()
        
        let pages: [TabBarPageType] = TabBarPageType.allCases
        let controllers: [UINavigationController] = pages.map {
            self.createTabNavigationController(of: $0)
        }
        self.configureTabBarController(with: controllers)
        self.tabBarController.delegate = self
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        if inset < 20 {
            self.tabBarController.additionalSafeAreaInsets.bottom = 12
        }
    }
    
    func currentPage() -> TabBarPageType? {
        TabBarPageType(index: self.tabBarController.selectedIndex)
    }

    func selectPage(_ page: TabBarPageType) {
        tabBarController.selectedIndex = page.pageOrderNumber
    }

    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPageType(index: index) else { return }
        tabBarController.selectedIndex = page.pageOrderNumber
    }
    
    private func configureTabbar() {
        let topLineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBarController.tabBar.frame.width, height: 0.25))
        topLineView.backgroundColor = UIColor.gray
        topLineView.layer.shadowColor = UIColor.black.cgColor
        topLineView.layer.shadowOffset = CGSize(width: 0, height: -2)
        topLineView.layer.shadowOpacity = 0.9
        topLineView.layer.shadowRadius = 4
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.tabBar.backgroundColor = UIColor.white
        tabBarController.tabBar.addSubview(topLineView)
    }
    
    private func createTabNavigationController(of page: TabBarPageType) -> LunchatNavigationController {
        let tabNavigationController = LunchatNavigationController()
        tabNavigationController.tabBarItem = self.configureTabBarItem(of: page)
        
        connectTabCoordinator(of: page, to: tabNavigationController)
        
        return tabNavigationController
    }
    
    private func configureTabBarItem(of page: TabBarPageType) -> UITabBarItem {
        
        var image = UIImage(named: page.iconName)
        var barItem: UITabBarItem
        
        if page == .lunchat {
            image = UIImage(named: page.iconName)?.withRenderingMode(.alwaysOriginal)
            barItem = UITabBarItem(title: page.pageTitle, image: image, tag: page.pageOrderNumber)
        } else {
            barItem = UITabBarItem(title: page.pageTitle, image: image, tag: page.pageOrderNumber)
        }

        return barItem
    }
    
    private func configureTabBarController(with tabViewControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabViewControllers, animated: true)
        tabBarController.selectedIndex = TabBarPageType.lunchat.pageOrderNumber
        
        tabBarController.tabBar.tintColor = AppColor.purple.color
        tabBarController.tabBar.barTintColor = AppColor.white.color
        tabBarController.tabBar.backgroundColor = AppColor.white.color
        tabBarController.view.backgroundColor = AppColor.white.color
        
        transitionAnimation()
        
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    private func connectTabCoordinator(of page: TabBarPageType, to tabNavigationController: LunchatNavigationController) {
        
        switch page {
        case .thread:
            let ThreadCoordinator = ThreadCoordinator(tabNavigationController)
            ThreadCoordinator.delegate = self
            childCoordinators.append(ThreadCoordinator)
            ThreadCoordinator.start()
        case .search:
            let searchCoordinator = SearchCoordinator(tabNavigationController)
            searchCoordinator.delegate = self
            childCoordinators.append(searchCoordinator)
            searchCoordinator.start()
        case .lunchat:
            let HomeCoordinator = HomeCoordinator(tabNavigationController)
            HomeCoordinator.delegate = self
            childCoordinators.append(HomeCoordinator)
            HomeCoordinator.start()
        case .chat:
            let chatCoordinator = ChatCoordinator(tabNavigationController)
            chatCoordinator.delegate = self
            childCoordinators.append(chatCoordinator)
            chatCoordinator.start()
        case .profile:
            let profileCoordinator = ProfileCoordinator(tabNavigationController)
            profileCoordinator.delegate = self
            childCoordinators.append(profileCoordinator)
            profileCoordinator.start()
        }
    }
}

extension TabBarCoordinator: CoordinatorDelegate {
    
    func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
    }
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tabBarItems = tabBarController.tabBar.items else { return }
        
        if tabBarController.selectedIndex == 2 {
            if let selectedImageView = tabBarItems[2].value(forKey: "view") as? UIView {
                for subview in selectedImageView.subviews {
                    if let imageView = subview as? UIImageView {
                        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                        rotationAnimation.fromValue = 0.0
                        rotationAnimation.toValue = CGFloat.pi * 2.0
                        rotationAnimation.duration = 1.0
                        rotationAnimation.repeatCount = 1
                        imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
                        let notification = Foundation.Notification(name: NSNotification.Name.reloadAppointments, object: nil)
                        NotificationCenter.default.post(notification)
                        break
                    }
                }
            }
        }
    }
}
