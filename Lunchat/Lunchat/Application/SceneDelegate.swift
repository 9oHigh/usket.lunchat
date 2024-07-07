//
//  SceneDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 2023/01/31.
//

import UIKit
import RxSwift
import RxKakaoSDKCommon
import KakaoSDKAuth
import NMapsMap
import SwiftyStoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var authCoordinator: AuthCoordinator?
    var rootNavigationController: LunchatNavigationController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        
        rootNavigationController = LunchatNavigationController()
        authCoordinator = AuthCoordinator(rootNavigationController ?? LunchatNavigationController())
        authCoordinator?.start()
        
        setSocialConfigure()
        setTabBarAppearance()
        fetchPurchaseTransaction()
        setImageCachePolicy(with: 104857600) // 100MB
        
        if let bottomInset = window?.safeAreaInsets.bottom {
            UserDefaults.standard.setSafeAreaInset(bottomInset)
        } else {
            UserDefaults.standard.setSafeAreaInset(-8)
        }
        
        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        SocketIOManager.shared.closeConnection()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 환경설정 화면 이후 다시 NotificationController로 돌아왔을 때, 확인
        NotificationCenter.default.post(name: NSNotification.Name.sceneDidBecomeActive, object: nil)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else { return }
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
}

extension SceneDelegate {
    
    func restart() {
        rootNavigationController = LunchatNavigationController()
        authCoordinator = AuthCoordinator(rootNavigationController ?? LunchatNavigationController())
        authCoordinator?.start()
        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    
    private func setSocialConfigure() {
        guard let clientId = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String,
              let kakaoAppKey = Bundle.main.infoDictionary!["KAKAO_APP_KEY"] as? String
        else {
            return
        }
        
        NMFAuthManager.shared().clientId = clientId
        RxKakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    private func setTabBarAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: AppFont.shared.getBoldFont(size: 12)], for: .normal)
    }
    
    private func setImageCachePolicy(with maximumBytes: Int) {
        UIImageView.configureCachePolicy(with: maximumBytes)
    }
    
    private func fetchPurchaseTransaction() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased:
                    // 결제는 완료되었으나 서버에 반영이 안되어있을 가능성이 있음
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                case .failed, .restored:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                    break
                case .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
