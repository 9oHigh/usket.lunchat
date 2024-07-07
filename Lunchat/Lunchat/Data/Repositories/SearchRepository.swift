//
//  SearchRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation
import Moya

final class SearchRepository: SearchRepositoryType {
    
    private let provider = MoyaProvider<SearchTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func searchPlace(place: String, display: Int, completion: @escaping (Result<SearchedPlaces?, APIError>) -> Void) {
        
        provider.request(.place(place: place, display: display)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let places = try? JSONDecoder().decode(SearchedPlacesDTO.self, from: response.data)
                    if let isEmpty = places?.isEmpty, isEmpty {
                        completion(.success(nil))
                    } else {
                        completion(.success(places?.compactMap ({$0.toObject()})))
                    }
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
    
    func searchUser(page: Int, take: Int, nickname: String, completion: @escaping (Result<SearchedUsers?, APIError>) -> Void) {
        
        provider.request(.user(page: page, take: take, nickname: nickname)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let users = try? JSONDecoder().decode(SearchedUsersDTO.self, from: response.data)
                    completion(.success(users?.toSearchedUsers()))
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
    
    func searchAppointment(page: Int, take: Int, keyword: String = "", option: String = "", completion: @escaping (Result<Appointments?, APIError>) -> Void) {
        
        provider.request(.appointment(page: page, take: take, keyword: keyword, option: option)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let appointments = try? JSONDecoder().decode(AppointmentsDTO.self, from: response.data)
                    completion(.success(appointments?.toAppointmentDetail()))
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
