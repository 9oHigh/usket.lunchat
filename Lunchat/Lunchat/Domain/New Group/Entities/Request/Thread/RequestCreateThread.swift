//
//  RequestCreateThread.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import Foundation

struct RequestCreateThread {
    var fileUrl: String?
    var title: String
    var content: String
    var placeTitle: String
    var placeAddress: String
    var placeRoadAddress: String
}

extension RequestCreateThread {
    static var empty: RequestCreateThread {
        return RequestCreateThread(fileUrl: nil, title: "", content: "", placeTitle: "", placeAddress: "", placeRoadAddress: "")
    }
}
