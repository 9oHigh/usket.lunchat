//
//  Appointment.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation

// MARK: - Appointments
struct Appointments: Equatable {
    let meta: Meta
    let data: [Appointment]
}

// MARK: - Appointment
struct Appointment: Equatable {
    let id, menu, matchMission: String
    let distance: Double
    let placeTitle, placeAddress, placeRoadAddress, placeLatitude: String
    let placeLongitude, placeArea: String
    let photoUrl: String
    let title: String
    let isOrganizer: Bool
    let organizerProfilePicture: String
    let organizerNickname, organizerBio: String
    let currParticipants, maxParticipants: Int
    let scheduledAt: String
    let remainingTime: Int
    let hashTags: [String]?
    let participants: [Participant]
}

extension Appointment {
    static var empty: Appointment {
        return .init(id: "empty", menu: "", matchMission: "", distance: 0, placeTitle: "", placeAddress: "", placeRoadAddress: "", placeLatitude: "", placeLongitude: "", placeArea: "", photoUrl: "", title: "", isOrganizer: false, organizerProfilePicture: "", organizerNickname: "", organizerBio: "", currParticipants: 0, maxParticipants: 0, scheduledAt: "", remainingTime: 0, hashTags: nil, participants: [])
    }
    
    static var recommend: Appointment {
        return .init(id: "recommend", menu: "", matchMission: "", distance: 0, placeTitle: "", placeAddress: "", placeRoadAddress: "", placeLatitude: "", placeLongitude: "", placeArea: "", photoUrl: "", title: "", isOrganizer: false, organizerProfilePicture: "", organizerNickname: "", organizerBio: "", currParticipants: 0, maxParticipants: 0, scheduledAt: "", remainingTime: 0, hashTags: nil, participants: [])
    }
}
