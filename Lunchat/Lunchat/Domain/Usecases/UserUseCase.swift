//
//  UserUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation
import RxSwift

final class UserUseCase {
    
    private let userRepository: UserRepositoryType
    let isAvailableNickname = PublishSubject<Bool>()
    let userInfo = PublishSubject<UserInformation?>()
    let userProfile = PublishSubject<Profile?>()
    let isUpdatedUserInfo = PublishSubject<Bool>()
    let isSettedCoords = PublishSubject<Bool>()
    let isReportedUser = PublishSubject<Bool>()
    let isSettedNotification = PublishSubject<Bool>()
    let isDeletedUser = PublishSubject<Bool>()
    
    init(userRepository: UserRepositoryType) {
        self.userRepository = userRepository
    }
    
    func checkUserNickname(nickname: String) {
        
        userRepository.checkUserNickname(nickname: nickname) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let available):
                if self.isAvailableNickname(nickname) {
                    self.isAvailableNickname.onNext(available.isAvailable)
                } else {
                    self.isAvailableNickname.onNext(false)
                }
            case .failure(_):
                self.isAvailableNickname.onNext(false)
            }
        }
    }
    
    func isAvailableNickname(_ nickname: String) -> Bool {
        let pattern = "^[가-힣a-zA-Z0-9]{4,10}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: nickname.count)
        let isAvailable = regex.numberOfMatches(in: nickname, range: range) == 1 ? true : false
        return isAvailable
    }
    
    func getUserInfo() {
        
        userRepository.getUserInfo { [weak self] result in
            switch result {
            case .success(let userInfo):
                if let userInfo = userInfo {
                    UserDefaults.standard.setUserInfo(.nickname, data: userInfo.nickname)
                    UserDefaults.standard.setUserInfo(.gender, data: userInfo.gender ? "true" : "false")
                    UserDefaults.standard.setUserInfo(.profilePicture, data: userInfo.profilePicture!)
                }
                self?.userInfo.onNext(userInfo)
            case .failure(_):
                self?.userInfo.onNext(nil)
            }
        }
    }
    
    func getUserProfile(nickname: String) {
        
        userRepository.getUserProfile(nickname: nickname) { [weak self] result in
            switch result {
            case .success(let profile):
                if let profile = profile {
                    self?.userProfile.onNext(profile)
                    if profile.nickname == UserDefaults.standard.getUserInfo(.nickname) {
                        UserDefaults.standard.setUserInfo(.nickname, data: profile.nickname)
                        UserDefaults.standard.setUserInfo(.bio, data: profile.bio)
                        UserDefaults.standard.setUserInfo(.gender, data: profile.gender ? "true": "false")
                    }
                } else {
                    self?.userProfile.onNext(nil)
                }
            case .failure(_):
                self?.userProfile.onNext(nil)
            }
        }
    }
    
    func updateUserInfo(userInfo: [String: Any]) {
        
        userRepository.updateUserInfo(updateUserInformation: userInfo) { [weak self] error in
            if error != nil {
                self?.isUpdatedUserInfo.onNext(false)
            } else {
                if let nickname = userInfo["nickname"] as? String {
                    UserDefaults.standard.setUserInfo(.nickname, data: nickname)
                }
                
                if let gender = userInfo["gender"] as? Bool {
                    UserDefaults.standard.setUserInfo(.gender, data: gender ? "true" : "false")
                }
                
                if let bio = userInfo["bio"] as? String {
                    UserDefaults.standard.setUserInfo(.bio, data: bio)
                }
                
                self?.isUpdatedUserInfo.onNext(true)
            }
        }
    }
    
    func setUserCoords(coords: Coordinate) {
        
        userRepository.setUserCoords(coords: coords) { [weak self] error in
            if error != nil {
                self?.isSettedCoords.onNext(false)
            } else {
                self?.isSettedCoords.onNext(true)
            }
        }
    }
    
    func reportUser(nickname: String, reason: String) {
        
        let requestReportUser = ReportUser(nickname: nickname, reason: reason)
        
        userRepository.reportUser(reportUser: requestReportUser) { [weak self] error in
            if error != nil {
                self?.isReportedUser.onNext(false)
            } else {
                self?.isReportedUser.onNext(true)
            }
        }
    }
    
    func setUserNotification(allowPushNotification: Bool) {
        
        userRepository.setUserNotification(allowPushNotification: allowPushNotification) { [weak self] error in
            if error != nil {
                self?.isSettedNotification.onNext(false)
            } else {
                self?.isSettedNotification.onNext(true)
            }
        }
    }
    
    func deleteUser(reason: String) {
        
        let requsetDeleteUser = DeleteUser(reason: reason)
        
        userRepository.deleteUser(deleteUser: requsetDeleteUser) { [weak self] error in
            if error != nil {
                self?.isDeletedUser.onNext(false)
            } else {
                self?.isDeletedUser.onNext(true)
            }
        }
    }
}
