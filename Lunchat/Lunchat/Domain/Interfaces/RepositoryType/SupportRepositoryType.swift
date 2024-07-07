//
//  SupportRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation

protocol SupportRepositoryType: AnyObject {
    func sendFeedback(feedback: Feedback, completion: @escaping (APIError?) -> Void)
}
