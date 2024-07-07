//
//  RequestCreateAppointment.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/06.
//

import Foundation

struct RequestCreateAppointment {
    var menu, placeTitle, placeAddress, placeRoadAddress: String
    var maxParticipants: Int
    var title: String
    var hashTags: [String]?
    var scheduledAt: String
}

extension RequestCreateAppointment {
    
    static var empty: RequestCreateAppointment {
        return RequestCreateAppointment(menu: "", placeTitle: "", placeAddress: "", placeRoadAddress: "", maxParticipants: 4, title: "", hashTags: [], scheduledAt: "")
    }
}
