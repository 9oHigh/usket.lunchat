//
//  AppointmentRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation
import Moya

final class AppointmentRepository: AppointmentRepositoryType {

    private let provider: MoyaProvider<AppointmentTarget> = MoyaProvider<AppointmentTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func getSchedule(completion: @escaping (Result<Appointment?, APIError>) -> Void) {
        
        provider.request(.getSchedule) { [weak self] result in
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
    
    func getAppointment(id: String, completion: @escaping (Result<Appointment?, APIError>) -> Void) {
        
        provider.request(.getAppointment(id: id)) { [weak self] result in
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
    
    func getAllAppointments(page: Int, take: Int, completion: @escaping (Result<Appointments?, APIError>) -> Void) {
        
        provider.request(.getAllAppointments(parameter: ["page": page, "take": take])) { [weak self] result in
  
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let appointments = try? JSONDecoder().decode(AppointmentsDTO.self, from: response.data)
                     completion(.success(appointments?.toAppointments()))
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
    
    func createAppointment(appointmentInfo: RequestCreateAppointment, completion: @escaping (Result<Appointment?, APIError>) -> Void) {
    
        provider.request(.createAppointment(parameters: ["menu": appointmentInfo.menu, "placeTitle": appointmentInfo.placeTitle, "placeAddress": appointmentInfo.placeAddress, "placeRoadAddress": appointmentInfo.placeRoadAddress, "maxParticipants": appointmentInfo.maxParticipants, "title": appointmentInfo.title, "hashTags": appointmentInfo.hashTags, "scheduleAt": appointmentInfo.scheduledAt])) { [weak self] result in
            
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
    
    func joinAppointment(appointmentId: String, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.joinAppointment(parameters: ["appointmentId": appointmentId])) { [weak self] result in
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
    
    func deleteAppointment(completion: @escaping (APIError?) -> Void) {
        
        provider.request(.deleteAppointment) { [weak self] result in
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
