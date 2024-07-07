//
//  CreateThreadRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import Foundation
import Moya

final class CreateThreadRepository: CreateThreadRepositoryType {
    
    private let provider = MoyaProvider<CreateThreadTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func createThread(info: RequestCreateThread, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.createPost(parameters: [
            "fileUrl": info.fileUrl,
            "title": info.title,
            "content": info.content,
            "placeTitle": info.placeTitle,
            "placeAddress" : info.placeAddress,
            "placeRoadAddress": info.placeRoadAddress
        ])) { result in
            
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
    
    func searchPlace(place: String, display: Int, completion: @escaping (Result<SearchedPlaces?, APIError>) -> Void) {
        
        provider.request(.place(place: place, display: display)) { result in
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
    
    func getLocationInfo(lat: Double, long: Double, completion: @escaping (Result<MapInfo?, APIError>) -> Void) {
        
        provider.request(.getLocationInfo(parameters: ["latitude": lat, "longitude": long])) { result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let infos = try? JSONDecoder().decode(MapInfoDTO.self, from: response.data)
                    if let empty = infos?.title.isEmpty, !empty {
                        completion(.success(infos?.toMapInfo()))
                    } else {
                        completion(.success(nil))
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
}
