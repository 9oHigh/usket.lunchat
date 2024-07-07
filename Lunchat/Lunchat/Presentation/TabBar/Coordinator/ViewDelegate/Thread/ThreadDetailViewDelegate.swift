//
//  ThreadDetailViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/9/24.
//

import Foundation

protocol ThreadDetailViewDelegate: AnyObject {
    func showDeleteThreadView(_ completion: @escaping () -> Void)
    func showDeleteThreadSuccess()
    func showDeleteThreadFailure()
}
