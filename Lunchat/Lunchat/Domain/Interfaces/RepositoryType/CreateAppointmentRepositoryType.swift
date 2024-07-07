//
//  CreateAppointmentRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/06.
//

import Foundation

protocol CreateAppointmentRepositoryType: AnyObject {
    func createAppointment(appointmentInfo: RequestCreateAppointment, completion: @escaping (Result<Appointment?,APIError>) -> Void)
    func searchPlace(place: String, display: Int, completion: @escaping (Result<SearchedPlaces?, APIError>) -> Void)
    func getLocationInfo(lat: Double, long: Double, completion: @escaping (Result<MapInfo?, APIError>) -> Void)
}
