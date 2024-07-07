//
//  FileDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

struct FilesDTO: Decodable {
    let meta: MetaDTO
    let data: [FileDTO]
}

struct FileDTO: Decodable {
    let presignedUrl: String
}

extension FilesDTO {
    func toFiles() -> Files {
        return .init(meta: meta.toMeta(), data: data.compactMap({ $0.toFile() }))
    }
}

extension FileDTO {
    func toFile() -> File {
        return .init(presignedUrl: presignedUrl)
    }
}
