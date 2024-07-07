//
//  NotificationRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import Foundation
import Moya

final class NotificationRepository: NotificationRepositoryType {
    
    private let provider = MoyaProvider<NotificationTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func getAllNotification(page: Int, take: Int, completion: @escaping (Result<Notifications?, APIError>) -> Void) {
        
        provider.request(.getAllNotification(parameters: ["page": page, "take": take])) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let notifications = try? JSONDecoder().decode(NotificationsDTO.self, from: response.data)
                    completion(.success(notifications?.toNotifications()))
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
    
    func getANotification(id: String, completion: @escaping (Result<Notification?, APIError>) -> Void) {
        
        provider.request(.getANotification(id: id)) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let notification = try? JSONDecoder().decode(NotificationDTO.self, from: response.data)
                    completion(.success(notification?.toNotification()))
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
    
    func readNotification(id: String, isRead: Bool, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.readNotification(id: id, isRead: isRead)) { result in
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
    
    func removeNotification(id: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.removeNotification(id: id)) { result in
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
}
