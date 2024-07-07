//
//  FIleTarget.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import UIKit
import Moya

enum FileTarget {
    case createPresignedURL(parameters: Parameters)
    case postImageToPresignedURL(parameters: PresignedUrl, data: UIImage)
    case getAllFileOfUser(parameters: Parameters)
}

extension FileTarget: TargetType {
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        switch self {
        case .createPresignedURL, .getAllFileOfUser:
            guard let lunchatURL = Bundle.main.infoDictionary?["LUNCHAT_URL"] as? String,
                  let url = URL(string: "https://" + lunchatURL)
            else {
                fatalError("fatal error - invalid api url")
            }
            return url
        case .postImageToPresignedURL(let presignedUrl, _):
            return URL(string: presignedUrl.presignedPost.url)!
        }
    }
    
    var path: String {
        switch self {
        case .createPresignedURL, .getAllFileOfUser:
            return "/file"
        case .postImageToPresignedURL:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createPresignedURL:
            return .post
        case .postImageToPresignedURL:
            return .post
        case .getAllFileOfUser:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .createPresignedURL(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .postImageToPresignedURL(parameters: let parameters, data: let image):
            let imageData = image.jpegData(compressionQuality: 0.1)
            let fields = parameters.presignedPost.fields
            let multipartFormData: [Moya.MultipartFormData] = [
                formData(for: fields.bucket, name: "bucket"),
                formData(for: fields.xAmzAlgorithm, name: "X-Amz-Algorithm"),
                formData(for: fields.xAmzCredential, name: "X-Amz-Credential"),
                formData(for: fields.xAmzDate, name: "X-Amz-Date"),
                formData(for: fields.key, name: "key"),
                formData(for: fields.policy, name: "Policy"),
                formData(for: fields.xAmzSignature, name: "X-Amz-Signature"),
                MultipartFormData(provider: .data(imageData!), name: "file")
            ]
            return .uploadMultipart(multipartFormData)
        case .getAllFileOfUser(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postImageToPresignedURL:
            return [
                "Content-Type": "multipart/form-data"
            ]
        case .createPresignedURL, .getAllFileOfUser:
            return [:]
        }
    }
    
    private func formData(for value: String, name: String) -> Moya.MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: .utf8)!), name: name)
    }
}
