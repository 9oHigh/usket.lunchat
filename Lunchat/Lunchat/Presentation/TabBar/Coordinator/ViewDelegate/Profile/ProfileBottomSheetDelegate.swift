//
//  ProfileBottomSheetDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/11/24.
//

import Foundation

protocol ProfileBottomSheetDelegate: AnyObject {
    // bottomSheet
    func showUserProfileView(nickname: String)
    
    // Ticket
    func showUseTicketView(nickname: String, viewModel: ProfileBottomSheetViewModel)
    func showUseTicketFailure()
    func showEmptyTicket()
    func showPersonalChatViewController(chatRoom: ChatRoom, _ initMessage: String?)
    
    // Report
    func showReportUserView(nickname: String, viewModel: ProfileBottomSheetViewModel)
    func showReportSuccess()
    func showReportFailure()
}
