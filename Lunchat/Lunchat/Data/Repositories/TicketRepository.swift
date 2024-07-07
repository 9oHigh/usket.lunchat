//
//  TicketRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import Foundation
import Moya

final class TicketRepository: TicketRepositoryType {
    
    private let provider: MoyaProvider<TicketTarget> = MoyaProvider<TicketTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func createTicket(ticket: Ticket, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.createTicket(parameters: ["paymentId": ticket.paymentId])) { [weak self] result in
            
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
    
    func getPurchaseHistory(page: Int, take: Int, completion: @escaping (Result<PurchaseHistories?, APIError>) -> Void) {
        
        provider.request(.getPurchaseHistory(parameters: ["page": page, "take": take])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let purchaseHistories = try? JSONDecoder().decode(PurchaseHistoriesDTO.self, from: response.data)
                    completion(.success(purchaseHistories?.toPurchaseHistories()))
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
    
    func getUseHistory(page: Int, take: Int, completion: @escaping (Result<UseHistories?, APIError>) -> Void) {
    
        provider.request(.getUseHistory(parameters: ["page": page, "take": take])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let useHistories = try? JSONDecoder().decode(UseHistoriesDTO.self, from: response.data)
                    completion(.success(useHistories?.toUseHistories()))
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
    
    func getUnUsedTicketCount(completion: @escaping (Result<CountUnUsed?, APIError>) -> Void) {
        
        provider.request(.getUnUsedCount) { [weak self] result in
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
}
