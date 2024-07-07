//
//  ProfileBottomSheetUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/18.
//

import Foundation
import RxSwift

final class ProfileBottomSheetUseCase {
    
    private let profileBottomSheetRepository: ProfileBottomSheetRepositoryType
    let userProfile = PublishSubject<Profile?>()
    let isReportedUser = PublishSubject<Bool>()
    let unUsedCount = PublishSubject<CountUnUsed?>()
    let roomId = PublishSubject<String?>()
    let chatRoom = PublishSubject<ChatRoom?>()
    
    init(profileBottomSheetRepository: ProfileBottomSheetRepositoryType) {
        self.profileBottomSheetRepository = profileBottomSheetRepository
    }
    
    func reportUser(nickname: String, reason: String) {
        
        let requestReportUser = ReportUser(nickname: nickname, reason: reason)
        
        profileBottomSheetRepository.reportUser(reportUser: requestReportUser) { [weak self] error in
            if error != nil {
                self?.isReportedUser.onNext(false)
            } else {
                self?.isReportedUser.onNext(true)
            }
        }
    }
    
    func getUserProfile(nickname: String) {
        
        profileBottomSheetRepository.getUserProfile(nickname: nickname) { [weak self] result in
            switch result {
            case .success(let profile):
                guard let profile = profile else { return }
                self?.userProfile.onNext(profile)
            case .failure(_):
                self?.userProfile.onNext(nil)
            }
        }
    }
    
    func getCountUnUsed() {
        
        profileBottomSheetRepository.getUnUsedTicketCount { [weak self] result in
            switch result {
            case .success(let unUsedCount):
                if let unUsedCount = unUsedCount {
                    self?.unUsedCount.onNext(unUsedCount)
                } else {
                    self?.unUsedCount.onNext(nil)
                }
            case .failure(_):
                self?.unUsedCount.onNext(nil)
            }
        }
    }
    
    func useTicket(toNickname: String) {
        
        profileBottomSheetRepository.useTicket(toNickname: toNickname) { [weak self] result in
            switch result {
            case .success(let roomId):
                if let roomId = roomId {
                    self?.roomId.onNext(roomId)
                } else {
                    self?.roomId.onNext(nil)
                }
            case .failure(_):
                self?.roomId.onNext(nil)
            }
        }
    }
    
    func getSpecificChatRoom(id: String) {
        
        profileBottomSheetRepository.getSpecificChatRoom(id: id) { [weak self] result in
            switch result {
            case .success(let chatRoom):
                if let chatRoom = chatRoom {
                    self?.chatRoom.onNext(chatRoom)
                } else {
                    self?.chatRoom.onNext(nil)
                }
            case .failure(_):
                self?.chatRoom.onNext(nil)
            }
        }
    }
}
