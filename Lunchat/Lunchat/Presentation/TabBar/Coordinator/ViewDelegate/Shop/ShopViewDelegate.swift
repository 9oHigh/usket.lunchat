//
//  ShopViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/11/24.
//

import Foundation

protocol ShopViewDelegate: AnyObject {
    func showTicketCreateView(ticket: TicketType, viewModel: PurchaseViewModel)
    func showTicketCreateSuccess()
    func showTicketCreateFailure()
}
