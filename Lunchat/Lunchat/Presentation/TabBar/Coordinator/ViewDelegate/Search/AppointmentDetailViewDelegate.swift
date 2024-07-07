//
//  AppointmentDetailViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/11/24.
//

import Foundation

protocol AppointmentDetailViewDelegate: AnyObject {
    func showAppointmentJoinSuccess()
    func showAppointmentJoinFailure()
    func showAppointmentJoinBottomSheet(checkAction: @escaping () -> Void)
}
