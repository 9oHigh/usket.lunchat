//
//  AlertManager.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/18.
//

import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
 
    func showSendImageMessage(_ parentViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alertViewController = UIAlertController(title: "사진 전송 안내", message: "해당 사진을 전송하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default) { action in
            completion(true)
        }
        let noAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive) { _ in
            completion(false)
        }
        
        alertViewController.addAction(noAction)
        alertViewController.addAction(yesAction)
        parentViewController.present(alertViewController, animated: true)
    }
    
    func showRestaurantPhotoPicker(_ parentViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alertViewController = UIAlertController(title: "사진 안내", message: "해당 사진을 업로드하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default) { action in
            completion(true)
        }
        let noAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive) { _ in
            completion(false)
        }
        
        alertViewController.addAction(noAction)
        alertViewController.addAction(yesAction)
        parentViewController.present(alertViewController, animated: true)
    }
    
    func showLeaveRoom(_ parentViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alertViewController = UIAlertController(title: "채팅 안내", message: "상대방이 채팅방을 나가셨습니다.", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
            completion(true)
        }
        
        alertViewController.addAction(yesAction)
        parentViewController.present(alertViewController, animated: true)
    }
    
    func showReLogin(_ completion: @escaping () -> Void) {
        let alertViewController = UIAlertController(title: "로그인 안내", message: "오랫동안 접속하지 않았거나 토큰이 만료되어 재로그인이 필요합니다.\n로그인 화면으로 이동합니다.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
            completion()
        }
        
        alertViewController.addAction(yesAction)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            if !UserDefaults.standard.isFirstAuthorizationPopup() {
                rootViewController.present(alertViewController, animated: true, completion: nil)
            }
        }
    }
}
