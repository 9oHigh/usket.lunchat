//
//  Coordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit

protocol CoordinatorDelegate: AnyObject {
    func didFinish(childCoordinator: Coordinator)
}

protocol Coordinator: AnyObject {
    var delegate: CoordinatorDelegate? { get set }
    var navigationController: LunchatNavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    var type: CoordinatorType { get }
    
    func start()
    func finish()
    
    init(_ navigationController: LunchatNavigationController)
}

extension Coordinator {
    
    func finish() {
        childCoordinators.removeAll()
    }
 
    func transitionAnimation() {
        if let window = UIApplication.shared.connectedScenes.compactMap ({ ($0 as? UIWindowScene)?.keyWindow }).last {
            
            UIView.transition(with: window,
                              duration: 1,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
    }
}
