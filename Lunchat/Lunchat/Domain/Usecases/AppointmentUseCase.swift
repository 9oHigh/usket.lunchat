//
//  AppointmentUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation
import RxSwift

final class AppointmentUseCase {
    
    private let appointmentRespository: AppointmentRepositoryType
    let appointment = PublishSubject<Appointment?>()
    let appointments = PublishSubject<Appointments?>()
    let schedule = PublishSubject<Appointment?>()
    let isJoined = PublishSubject<Bool>()
    let isLeft = PublishSubject<Bool>()
    
    init(appointmentRespository: AppointmentRepositoryType) {
        self.appointmentRespository = appointmentRespository
    }
    
    func getScheduleOfUser() {
        
        appointmentRespository.getSchedule { [weak self] result in
            switch result {
            case .success(let schedule):
                if let schedule = schedule {
                    self?.schedule.onNext(schedule)
                } else {
                    self?.schedule.onNext(nil)
                }
            case .failure(_):
                self?.schedule.onNext(nil)
            }
        }
    }
    
    func getAppointment(id: String) {
        
        appointmentRespository.getAppointment(id: id) { [weak self] result in
            switch result {
            case .success(let appointment):
                if let appointment = appointment {
                    self?.appointment.onNext(appointment)
                } else {
                    self?.appointment.onNext(nil)
                }
            case .failure(_):
                self?.appointment.onNext(nil)
            }
        }
    }
    
    func getAllAppointments(page: Int, take: Int, completion: @escaping () -> Void = {}) {
        
        appointmentRespository.getAllAppointments(page: page, take: take) { [weak self] result in
            
            switch result {
            case .success(let appointments):
                if let appointments = appointments {
                    self?.appointments.onNext(appointments)
                    completion()
                } else {
                    self?.appointments.onNext(nil)
                }
            case .failure(_):
                self?.appointments.onNext(nil)
            }
        }
    }
    
    func createAppointment(appointmentInfo: RequestCreateAppointment) {
        
        appointmentRespository.createAppointment(appointmentInfo: appointmentInfo) { [weak self] result in
            switch result {
            case .success(let appointment):
                if let appointment = appointment {
                    self?.appointment.onNext(appointment)
                } else {
                    self?.appointment.onNext(nil)
                }
            case .failure(_):
                self?.appointment.onNext(nil)
            }
        }
    }
    
    func deleteAppointment() {
        
        appointmentRespository.deleteAppointment { [weak self] error in
            if let error = error {
                self?.isLeft.onNext(false)
            } else {
                self?.isLeft.onNext(true)
            }
        }
    }
    
    func joinAppointment(appointmentId: String) {
        
        appointmentRespository.joinAppointment(appointmentId: appointmentId) { [weak self] error in
            if let error = error {
                self?.isJoined.onNext(false)
            } else {
                self?.isJoined.onNext(true)
            }
        }
    }
}
