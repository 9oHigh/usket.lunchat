//
//  AppointmentDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

struct AppointmentsDTO: Decodable {
    let meta: MetaDTO
    let data: [AppointmentDTO]
}

struct AppointmentDTO: Decodable {
    let id, menu, matchMission: String
    let distance: Double
    let placeTitle, placeAddress, placeRoadAddress, placeLatitude: String
    let placeLongitude, placeArea: String
    let photoUrl: String
    let title: String
    let isOrganizer: Bool
    let organizerProfilePicture: String
    let organizerNickname, organizerBio: String
    let participants: [ParticipantDTO]
    let currParticipants, maxParticipants: Int
    let scheduledAt: String
    let remainingTime: Int
    let hashTags: [String]?

    enum CodingKeys: String, CodingKey {
        case id, menu, matchMission, distance, placeTitle, placeAddress, placeRoadAddress, placeLatitude, placeLongitude, placeArea, photoUrl
        case title, isOrganizer, organizerProfilePicture, organizerNickname, organizerBio, participants, currParticipants, maxParticipants, scheduledAt, remainingTime, hashTags
    }
}

struct ParticipantDTO: Decodable {
    let profilePicture: String
    let nickname, bio: String
}

extension AppointmentsDTO {
    func toAppointments() -> Appointments {
        let appointments = data.map { $0.toAppointment() }
        let meta = meta.toMeta()
        return .init(meta: meta, data: appointments)
    }
    
    func toAppointmentDetail() -> Appointments {
        let appointments = data.map { $0.toAppointmentDetail() }
        let meta = meta.toMeta()
        return .init(meta: meta, data: appointments)
    }
}

extension AppointmentDTO {
    func toAppointment() -> Appointment {
        return .init(id: id, menu: menu, matchMission: matchMission, distance: distance, placeTitle: placeTitle, placeAddress: placeAddress, placeRoadAddress: placeRoadAddress, placeLatitude: placeLatitude, placeLongitude: placeLongitude, placeArea: placeArea, photoUrl: photoUrl, title: title, isOrganizer: isOrganizer, organizerProfilePicture: organizerProfilePicture, organizerNickname: organizerNickname, organizerBio: organizerBio, currParticipants: currParticipants, maxParticipants: maxParticipants, scheduledAt: scheduledAt.toAppointmentTime, remainingTime: remainingTime, hashTags: hashTags, participants: participants.compactMap { $0.toParticipant() })
    }
    
    func toAppointmentDetail() -> Appointment {
        return .init(id: id, menu: menu, matchMission: matchMission, distance: distance, placeTitle: placeTitle, placeAddress: placeAddress, placeRoadAddress: placeRoadAddress, placeLatitude: placeLatitude, placeLongitude: placeLongitude, placeArea: placeArea, photoUrl: photoUrl, title: title, isOrganizer: isOrganizer, organizerProfilePicture: organizerProfilePicture, organizerNickname: organizerNickname, organizerBio: organizerBio, currParticipants: currParticipants, maxParticipants: maxParticipants, scheduledAt: scheduledAt, remainingTime: remainingTime, hashTags: hashTags, participants: participants.compactMap { $0.toParticipant() })
    }
}

extension ParticipantDTO {
    func toParticipant() -> Participant {
        return .init(profilePicture: profilePicture, nickname: nickname, bio: bio)
    }
}
