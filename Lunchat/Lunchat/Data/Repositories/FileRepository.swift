//
//  FileRepository.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import Moya
import UIKit

final class FileRepository: FileRepositoryType {
 
    private let provider: MoyaProvider<FileTarget> = MoyaProvider<FileTarget>(session: Session(interceptor: TokenInterceptor.shared), plugins: [LoggingPlugin()])
    
    func createPresignedUrl(fileExt: FileExt, completion: @escaping (Result<PresignedUrl?, APIError>) -> Void) {
        
        provider.request(.createPresignedURL(parameters: ["fileExt": fileExt.fileExt])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let presignedUrlDTO = try? JSONDecoder().decode(PresignedUrlDTO.self, from: response.data)
                    completion(.success(presignedUrlDTO?.toPresignedUrl()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    func postImageToPresignedUrl(presignedUrl: PresignedUrl, data: UIImage, completion: @escaping (APIError?) -> Void) {
        
        provider.request(.postImageToPresignedURL(parameters: presignedUrl, data: data)) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    completion(nil)
                } else {
                    completion(APIError(rawValue: response.statusCode) ?? .unknown)
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(APIError(rawValue: responseError.statusCode) ?? .unknown)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func getAllFiles(page: Int, take: Int, completion: @escaping (Result<Files?, APIError>) -> Void) {
        
        provider.request(.getAllFileOfUser(parameters: ["page": page, "take": take])) { [weak self] result in
            switch result {
            case .success(let response):
                if let _ = try? response.filter(statusCodes: 200...299) {
                    let filesDTO = try? JSONDecoder().decode(FilesDTO.self, from: response.data)
                    completion(.success(filesDTO?.toFiles()))
                } else {
                    completion(.failure(APIError(rawValue: response.statusCode) ?? .unknown))
                }
            case .failure(let error):
                if let responseError = error.response {
                    completion(.failure(APIError(rawValue: responseError.statusCode) ?? .unknown))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
