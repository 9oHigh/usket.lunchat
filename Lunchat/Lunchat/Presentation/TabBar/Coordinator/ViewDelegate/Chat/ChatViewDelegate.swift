//
//  ChatViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/11/24.
//

import Foundation

protocol ChatViewDelegate: AnyObject {
    func showPhotosViewController(with imageDatas: [String : [FileInfo]])
    func showPhotoDetail(photoUrl: String, date: String)
    func showChatExitRoom(isPrivate: Bool)
    func showChatExitRoomImpossible()
    func showUserProfileView(nickname: String)
}
