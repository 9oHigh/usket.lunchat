//
//  ProfileBottomSheetRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/18.
//

import Foundation
import Moya

final class ProfileBottomSheetRepository: ProfileBottomSheetRepositoryType {

    private let provider = MoyaProvider<ProfileBottomSheetTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func getUserProfile(nickname: String, completion: @escaping (Result<Profile?, APIError>) -> Void) {
        
        provider.request(.getUserProfile(parameters: ["nickname": nickname])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let profile = try? JSONDecoder().decode(ProfileDTO.self, from: response.data)
                    completion(.success(profile?.toProfile()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func reportUser(reportUser: ReportUser, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.reportUser(parameters: ["nickname": reportUser.nickname, "reason": reportUser.reason])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func getUnUsedTicketCount(completion: @escaping (Result<CountUnUsed?, APIError>) -> Void) {
        
        provider.request(.getUserTicketCount) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let unUsedCount = try? JSONDecoder().decode(CountUnUsedDTO.self, from: response.data)
                    completion(.success(unUsedCount?.toCountUnUed()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func useTicket(toNickname: String, completion: @escaping (Result<String?, APIError>) -> Void) {
        
        provider.request(.useTicket(parameters: ["toNickname": toNickname])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let roomId = try? JSONDecoder().decode(UseTicketRoomIdDTO.self, from: response.data)
                    completion(.success(roomId?.roomId))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func getSpecificChatRoom(id: String, completion: @escaping (Result<ChatRoom?, APIError>) -> Void) {
        provider.request(.getSpecificChatRoom(id: id)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let chatRoom = try? JSONDecoder().decode(ChatRoomDTO.self, from: response.data)
                    completion(.success(chatRoom?.toChatRoom()))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
