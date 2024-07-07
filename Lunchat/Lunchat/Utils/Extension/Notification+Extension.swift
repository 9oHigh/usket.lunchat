//
//  Notification+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 1/19/24.
//

import Foundation

// MARK: - Notification 최대한 줄이기, 분명 줄일 수 있을 거임 ( 리팩토링 )
extension NSNotification.Name {
    
    // MARK: - Scene
    
    static let sceneDidBecomeActive = NSNotification.Name("sceneDidBecomeActive")
    
    // MARK: - Home
    
    static let reloadAppointments = NSNotification.Name("reloadAppointments")
    
    // MARK: - Thread
    
    static let reloadLikedPosts = NSNotification.Name("reloadLikedPosts")
    static let reloadSharedPosts = NSNotification.Name("reloadSharedPosts")
    static let reloadPosts = NSNotification.Name("reloadPosts")
    static let threadLeftGesture = NSNotification.Name("threadLeftGesture")
    static let reloadLocation = NSNotification.Name("reloadLocation")
    
    // MARK: - Chat
    
    static let leaveRoom = NSNotification.Name("leaveRoom")
    static let leaveRoomSuccess = NSNotification.Name("leaveRoomSuccess")
    static let chatRightGesture = NSNotification.Name("chatRightGesture")
    static let chatLeftGesture = NSNotification.Name("chatLeftGesture")
    static let recievedMessage = NSNotification.Name("recievedMessage")
    static let findAllMessages = NSNotification.Name("findAllMessages")
    static let removeSideMenu = NSNotification.Name("removeSideMenu")
    static let reloadChatRooms = NSNotification.Name("reloadChatRooms")
    static let sortChatList = NSNotification.Name("sortChatList")
    
    // MARK: - Shop
    
    static let addLoadingView = NSNotification.Name("addLoadingView")
    static let removeLoadingView = NSNotification.Name("removeLoadingView")
    static let ticketCount = NSNotification.Name("ticketCount")
    
    // MARK: - Search
    
    static let searchLeftGesture = NSNotification.Name("searchLeftGesture")
    static let hideKeyboard = NSNotification.Name("hideKeyboard")
    static let searchAppointment = NSNotification.Name("searchAppointment")
    static let searchUser = NSNotification.Name("searchUser")
    static let searchAppointmentRefresh = NSNotification.Name("searchAppointmentRefresh")
    
    // MARK: - SignUp
    
    static let termType = NSNotification.Name("termType")
}
