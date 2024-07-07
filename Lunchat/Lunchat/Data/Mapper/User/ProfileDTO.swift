//
//  ProfileDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/06.
//

import Foundation

struct ProfileDTO: Decodable {
    let id: String
    let profilePicture: String?
    let nickname, bio: String
    let gender: Bool
    let receivedTicketsCount, appointmentCreationCount, appointmentParticipationCount: Int
}

extension ProfileDTO {
    func toProfile() -> Profile {
        return .init(id: id, profilePicture: profilePicture, nickname: nickname, bio: bio, gender: gender, receivedTicketsCount: receivedTicketsCount, appointmentCreationCount: appointmentCreationCount, appointmentParticipationCount: appointmentParticipationCount)
    }
}
