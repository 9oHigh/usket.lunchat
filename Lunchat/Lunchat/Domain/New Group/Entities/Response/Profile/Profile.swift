//
//  Profile.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/06.
//

import Foundation

struct Profile {
    let id: String
    let profilePicture: String?
    let nickname, bio: String
    let gender: Bool
    let receivedTicketsCount, appointmentCreationCount, appointmentParticipationCount: Int
    
    func toProfileInfoCount() -> ProfileInfoCount {
        return .init(receivedTicketsCount: receivedTicketsCount, appointmentCreationCount: appointmentCreationCount, appointmentParticipationCount: appointmentParticipationCount)
    }
}
