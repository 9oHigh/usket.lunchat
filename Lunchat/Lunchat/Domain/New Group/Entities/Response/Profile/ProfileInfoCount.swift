//
//  ProfileInfoCount.swift
//  Lunchat
//
//  Created by 이경후 on 4/3/24.
//

import Foundation

struct ProfileInfoCount {
    var receivedTicketsCount: Int
    var appointmentCreationCount: Int
    var appointmentParticipationCount: Int
    
    init(receivedTicketsCount: Int, appointmentCreationCount: Int, appointmentParticipationCount: Int) {
        self.receivedTicketsCount = receivedTicketsCount
        self.appointmentCreationCount = appointmentCreationCount
        self.appointmentParticipationCount = appointmentParticipationCount
    }
}
