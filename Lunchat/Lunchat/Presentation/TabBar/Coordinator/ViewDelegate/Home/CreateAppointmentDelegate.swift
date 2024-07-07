//
//  CreateAppointmentDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/15/24.
//

import Foundation

protocol CreateAppointmentDelegate: AnyObject {
    // viewControllers
    func showTimeViewController(menuType: MenuType)
    func showParticipiantViewController(date: Date)
    func showLocationViewController(count: Int)
    func showMapViewController(lat: Double, long: Double)
    func showInfoViewController(locationInfo: SearchedPlace)
    
    // bottomSheets
    func showInAccessableLocation()
    func showMapChosenFailure()
    func showAppointmentCreate(request: RequestCreateAppointment, viewModel: CreateAppointmentViewModel)
    
    // coordinator delegate
    func finishCoordinator()
    
    // etc
    func getAppointment() -> RequestCreateAppointment
}
