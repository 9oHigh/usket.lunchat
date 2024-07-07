//
//  PresignedUrl.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/26.
//

import Foundation

struct PresignedUrl: Equatable {
    let presignedPost: PresignedPost
    let fileID: String
}

struct PresignedPost: Equatable {
    let url: String
    let fields: Fields
}

struct Fields: Equatable {
    let bucket, xAmzAlgorithm, xAmzCredential, xAmzDate: String
    let key, policy, xAmzSignature: String
}
