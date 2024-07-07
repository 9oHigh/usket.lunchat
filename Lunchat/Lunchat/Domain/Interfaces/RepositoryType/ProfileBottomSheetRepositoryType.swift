//
//  ProfileBottomSheetRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/18.
//

import Foundation

protocol ProfileBottomSheetRepositoryType: AnyObject {
    func getUserProfile(nickname: String, completion: @escaping (Result<Profile?, APIError>) -> Void)
    func reportUser(reportUser: ReportUser, completion: @escaping (APIError?) -> Void)
    func getUnUsedTicketCount(completion: @escaping (Result<CountUnUsed?, APIError>) -> Void)
    func useTicket(toNickname: String, completion: @escaping (Result<String?, APIError>) -> Void)
    func getSpecificChatRoom(id: String, completion: @escaping (Result<ChatRoom?, APIError>) -> Void)
}
