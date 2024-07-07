//
//  APIError.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

enum APIError: Int, Error {
    case clientError = 400
    case inValidTokenError = 401
    case inValidURL = 404
    case serverError = 500
    case unknown
}
