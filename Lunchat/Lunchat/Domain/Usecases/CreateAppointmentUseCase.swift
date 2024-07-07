//
//  CreateAppointmentUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/06.
//

import Foundation
import RxSwift

final class CreateAppointmentUseCase {
    
    private let createAppointmentRepository: CreateAppointmentRepositoryType
    let places = PublishSubject<SearchedPlaces?>()
    let appointment = PublishSubject<Appointment?>()
    let mapInfo = PublishSubject<MapInfo?>()
    
    init(createAppointmentRepository: CreateAppointmentRepositoryType) {
        self.createAppointmentRepository = createAppointmentRepository
    }
    
    func searchPlace(place: String, display: Int = 5) {
        
        createAppointmentRepository.searchPlace(place: place, display: display) { [weak self] result in
            switch result {
            case .success(let places):
                if let places = places {
                    self?.places.onNext(places)
                } else {
                    self?.places.onNext(nil)
                }
            case .failure(_):
                self?.places.onNext(nil)
            }
        }
    }
    
    func createAppointment(appointmentInfo: RequestCreateAppointment) {
        
        createAppointmentRepository.createAppointment(appointmentInfo: appointmentInfo) { [weak self] result in
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
    
    func getLocationInfo(lat: Double, long: Double) {
        
        createAppointmentRepository.getLocationInfo(lat: lat, long: long) { [weak self] result in
            switch result {
            case .success(let info):
                if let info = info {
                    self?.mapInfo.onNext(info)
                } else {
                    self?.mapInfo.onNext(nil)
                }
            case .failure(_):
                self?.mapInfo.onNext(nil)
            }
        }
    }
}

