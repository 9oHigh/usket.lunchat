//
//  ChatRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation
import Moya

final class ChatRepository: ChatRepositoryType {
    
    private let provider = MoyaProvider<ChatTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func getChatRooms(page: Int, take: Int, isPrivate: Bool, completion: @escaping (Result<ChatRooms?, APIError>) -> Void) {
        
        provider.request(.getChatRooms(page: page, take: take, isPrivate: isPrivate)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let chatRooms = try? JSONDecoder().decode(ChatRoomsDTO.self, from: response.data)
                    completion(.success(chatRooms?.toChatRooms()))
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
