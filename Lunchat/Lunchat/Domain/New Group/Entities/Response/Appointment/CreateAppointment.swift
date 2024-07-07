//
//  CreateAppointment.swift
//  Lunchat
//
//  Created by 이경후 on 4/3/24.
//

import Foundation

struct CreateAppointment: Equatable {
    var menu, eatPlaceTitle, eatPlaceAddress, eatPlaceRoadAddress: String
    var meetPlaceTitle, meetPlaceAddress, meetPlaceRoadAddress: String
    var maxParticipants: Int
    var title: String
    var closedAt, scheduledAt: String
}
