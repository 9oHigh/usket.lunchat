//
//  AppointmentRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

protocol AppointmentRepositoryType: AnyObject {
    func getSchedule(completion: @escaping (Result<Appointment?, APIError>)-> Void)
    func getAppointment(id: String, completion: @escaping (Result<Appointment?, APIError>) -> Void)
    func getAllAppointments(page: Int, take: Int, completion: @escaping (Result<Appointments?, APIError>)-> Void)
    func createAppointment(appointmentInfo: RequestCreateAppointment, completion: @escaping (Result<Appointment?,APIError>) -> Void)
    func joinAppointment(appointmentId: String, completion: @escaping (APIError?) -> Void)
    func deleteAppointment(completion: @escaping (APIError?) -> Void)
}
