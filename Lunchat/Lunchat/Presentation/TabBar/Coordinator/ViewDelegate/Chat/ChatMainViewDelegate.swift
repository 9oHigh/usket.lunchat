//
//  ChatMainViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/11/24.
//

import Foundation

protocol ChatMainViewDelegate: AnyObject {
    func showAppointmentChatViewController(chatRoom: ChatRoom)
    func showPersonalChatViewController(chatRoom: ChatRoom, _ initMessage: String?)
}
