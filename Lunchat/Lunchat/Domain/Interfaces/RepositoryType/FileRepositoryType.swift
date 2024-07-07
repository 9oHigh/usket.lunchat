//
//  FileRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import UIKit

protocol FileRepositoryType: AnyObject {
    func createPresignedUrl(fileExt: FileExt, completion: @escaping (Result<PresignedUrl?, APIError>) -> Void)
    func postImageToPresignedUrl(presignedUrl: PresignedUrl, data: UIImage, completion: @escaping (APIError?) -> Void)
    func getAllFiles(page: Int, take: Int, completion: @escaping (Result<Files?, APIError>) -> Void)
}
