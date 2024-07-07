//
//  AppointmentTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation
import Moya

enum AppointmentTarget {
    case getSchedule
    case getAppointment(id: String)
    case getAllAppointments(parameter: Parameters)
    case createAppointment(parameters: Parameters)
    case joinAppointment(parameters: Parameters)
    case deleteAppointment
}

extension AppointmentTarget: TargetType {
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        guard let lunchatURL = Bundle.main.infoDictionary?["LUNCHAT_URL"] as? String,
              let url = URL(string: "https://" + lunchatURL)
        else {
            fatalError("fatal error - invalid api url")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getSchedule:
            return "/appointment/scheduled"
        case .getAppointment(id: let id):
            return "/appointment/\(id)"
        case .getAllAppointments, .createAppointment, .deleteAppointment:
            return "/appointment"
        case .joinAppointment:
            return "/appointment/join"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSchedule, .getAppointment,.getAllAppointments:
            return .get
        case .createAppointment, .joinAppointment:
            return .post
        case .deleteAppointment:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getSchedule, .deleteAppointment:
            return .requestPlain
        case .getAppointment(id: let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .getAllAppointments(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .joinAppointment(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .createAppointment(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getSchedule,.getAppointment ,.getAllAppointments, .joinAppointment, .deleteAppointment, .createAppointment:
            return [:]
        }
    }
}
