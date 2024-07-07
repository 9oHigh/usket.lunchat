//
//  PresignedUrl.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/26.
//

import Foundation

struct PresignedUrlDTO: Decodable {
    let presignedPost: PresignedPostDTO
    let fileID: String

    enum CodingKeys: String, CodingKey {
        case presignedPost
        case fileID = "fileId"
    }
}

struct PresignedPostDTO: Decodable {
    let url: String
    let fields: FieldsDTO
}

struct FieldsDTO: Decodable {
    let bucket, xAmzAlgorithm, xAmzCredential, xAmzDate: String
    let key, policy, xAmzSignature: String

    enum CodingKeys: String, CodingKey {
        case bucket
        case xAmzAlgorithm = "X-Amz-Algorithm"
        case xAmzCredential = "X-Amz-Credential"
        case xAmzDate = "X-Amz-Date"
        case key
        case policy = "Policy"
        case xAmzSignature = "X-Amz-Signature"
    }
}

extension PresignedUrlDTO {
    func toPresignedUrl() -> PresignedUrl {
        return .init(presignedPost: presignedPost.toPresignedPost(), fileID: fileID)
    }
}

extension PresignedPostDTO {
    func toPresignedPost() -> PresignedPost {
        return .init(url: url, fields: fields.toFields())
    }
}

extension FieldsDTO {
    func toFields() -> Fields {
        return .init(bucket: bucket, xAmzAlgorithm: xAmzAlgorithm, xAmzCredential: xAmzCredential, xAmzDate: xAmzDate, key: key, policy: policy, xAmzSignature: xAmzSignature)
    }
}
