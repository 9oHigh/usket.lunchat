//
//  CreateAppointmentRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/06.
//

import Foundation
import Moya

final class CreateAppointmentRepository: CreateAppointmentRepositoryType {

    private let provider = MoyaProvider<CreateAppointmentTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func createAppointment(appointmentInfo: RequestCreateAppointment, completion: @escaping (Result<Appointment?, APIError>) -> Void) {
        
        provider.request(.createAppointment(parameters: ["menu": appointmentInfo.menu, "placeTitle": appointmentInfo.placeTitle, "placeAddress": appointmentInfo.placeAddress, "placeRoadAddress": appointmentInfo.placeRoadAddress, "maxParticipants": appointmentInfo.maxParticipants, "title": appointmentInfo.title, "hashTags": appointmentInfo.hashTags, "scheduledAt": appointmentInfo.scheduledAt])) { result in
            
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let appointment = try? JSONDecoder().decode(AppointmentDTO.self, from: response.data)
                    completion(.success(appointment?.toAppointment()))
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
