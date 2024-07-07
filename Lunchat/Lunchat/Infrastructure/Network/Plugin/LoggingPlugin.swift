//
//  LoggingPlugin.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/27.
//

import Foundation
import Moya

struct LoggingPlugin: PluginType {
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            let statusCode = response.statusCode
            let json = try? response.mapJSON()
            let string = try? response.mapString()
            print("Received response:\nstatusCode: \(String(describing: statusCode))\n message: \(String(describing: json == nil ? string : json))\n", "path: \(target.path)")
        case .failure(let error):
            let statusCode = error.response?.statusCode
            let json = try? error.response?.mapJSON()
            let string = try? error.response?.mapString()
            print("Received response:\nstatusCode: \(String(describing: statusCode))\n message: \(String(describing: json == nil ? string : json))\n", "path: \(target.path)")
        }
    }
}
