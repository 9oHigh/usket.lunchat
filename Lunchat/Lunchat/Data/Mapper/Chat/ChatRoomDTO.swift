//
//  ChatRoomDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation

struct ChatRoomsDTO: Decodable {
    let meta: MetaDTO
    let data: [ChatRoomDTO]
}

struct ChatRoomDTO: Decodable {
    let id: String
    let isPrivate, isClosed: Bool
    let currParticipants, maxParticipants: Int
    let participants: [ParticipantDTO]
    let files: [FileInfoDTO]?
}

struct FileInfoDTO: Decodable {
    let fileID: String
    let fileURL: String
    let fileType, createdAt: String

    enum CodingKeys: String, CodingKey {
        case fileID = "fileId"
        case fileURL = "fileUrl"
        case fileType, createdAt
    }
}

extension ChatRoomsDTO {
    func toChatRooms() -> ChatRooms {
        return .init(meta: meta.toMeta(), data: data.compactMap { $0.toChatRoom() } )
    }
}

extension ChatRoomDTO {
    func toChatRoom() -> ChatRoom {
        return .init(id: id, isPrivate: isPrivate, isClosed: isClosed, currParticipants: currParticipants, maxParticipants: maxParticipants, participants: participants.compactMap { $0.toParticipant() }, files: files?.compactMap { $0.toFileInfo() }, lastMessage: nil)
    }
}

extension FileInfoDTO {
    func toFileInfo() -> FileInfo {
        return .init(fileID: fileID, fileURL: fileURL, fileType: fileType, createdAt: createdAt)
    }
}
