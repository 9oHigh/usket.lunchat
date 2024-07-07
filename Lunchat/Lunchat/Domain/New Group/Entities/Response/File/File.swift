//
//  File.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Foundation

struct Files: Equatable {
    let meta: Meta
    let data: [File]
}

struct File: Equatable {
    let presignedUrl: String
}
