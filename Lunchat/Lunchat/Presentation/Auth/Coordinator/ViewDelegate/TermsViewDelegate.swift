//
//  TermsViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/8/24.
//

import Foundation

protocol TermsViewDelegate: AnyObject {
    func showDetailTerm(type: TermType)
    func showInvalidConfirm()
    func showSignupSuccess()
    func showSignupFailure()
}
