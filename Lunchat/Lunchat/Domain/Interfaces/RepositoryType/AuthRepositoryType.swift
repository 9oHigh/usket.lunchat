//
//  AuthRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

protocol AuthRepositoryType: AnyObject {
    func socialSignup(userInfo: SignupSocial, completion: @escaping (Result<Tokens?, APIError>) -> Void)
    func socialLogin(info: LoginSocial, completion: @escaping (Result<Tokens?, APIError>) -> Void)
    func logout(completion: @escaping (APIError?) -> Void)
    func refreshToken(refreshToken: String, completion: @escaping (Result<Tokens?, APIError>) -> Void)
}
