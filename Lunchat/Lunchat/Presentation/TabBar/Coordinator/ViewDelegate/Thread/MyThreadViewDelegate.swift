//
//  MyThreadViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/9/24.
//

import Foundation

protocol MyThreadViewDelegate: AnyObject {
    func showThreadDetail(id: String, isShared: Bool)
    func moveToCreateThreadCoordinator()
}
