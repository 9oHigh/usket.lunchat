//
//  HomeCellDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/12/24.
//

import Foundation

protocol HomeCellDelegate: AnyObject {
    // CreateAppointmentCellViewModel
    func moveToCreateAppointmentCoordinator()
    
    // AppointmentCellViewModel
    func showAppointmentJoinView(id: String, viewModel: HomeAppointmentCellViewModel)
    func showAppointmentCancelView(viewModel: HomeAppointmentCellViewModel)
    func showAppointmentLeaveView(viewModel: HomeAppointmentCellViewModel)
}
