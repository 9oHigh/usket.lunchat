//
//  DeviceTokenManager.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/14.
//

import Foundation
import Moya

final class DeviceTokenManager {
    
    static let shared = DeviceTokenManager()
    
    let provider: MoyaProvider<UserTarget> = MoyaProvider<UserTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func setUserDeviceToken(token: String) {
        provider.request(.setDeviceToken(parameters: ["deviceToken": token])) { _ in }
    }
}
