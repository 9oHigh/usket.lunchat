//
//  FileUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/03.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

final class FileUseCase {
    
    private let fileRepository: FileRepositoryType
    let albumPermission = PublishSubject<Bool>()
    let presignedUrl = PublishSubject<String?>()
    let isSuceessPost = PublishSubject<Bool>()
    let allFiles = BehaviorRelay<[File]>(value: [])
    let allFilesMeta = PublishSubject<Meta>()
    let fileId = PublishSubject<String>()
    
    init(fileRepository: FileRepositoryType) {
        self.fileRepository = fileRepository
    }
    
    func createPresignedUrl(image: UIImage, imageType: FileExt) {
        
        fileRepository.createPresignedUrl(fileExt: imageType) { [weak self] result in
            switch result {
            case .success(let url):
                if let presignedUrl = url  {
                    self?.postImageToPresignedUrl(presignedUrl: presignedUrl, data: image)
                } 
            case .failure(_):
                self?.presignedUrl.onNext(nil)
            }
        }
    }
    
    func postImageToPresignedUrl(presignedUrl: PresignedUrl, data: UIImage) {
        
        fileRepository.postImageToPresignedUrl(presignedUrl: presignedUrl, data: data) { [weak self] error in
            guard error != nil else {
                self?.fileId.onNext(presignedUrl.fileID)
                self?.presignedUrl.onNext(presignedUrl.presignedPost.url + presignedUrl.presignedPost.fields.key)
                self?.isSuceessPost.onNext(true)
                return
            }
            self?.isSuceessPost.onNext(false)
        }
    }
    
    func getAllFiles(page: Int, take: Int) {
        
        fileRepository.getAllFiles(page: page, take: take) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let files):
                if let files = files {
                    let combinedValue = self.allFiles.value + files.data
                    self.allFiles.accept(combinedValue)
                    self.allFilesMeta.onNext(files.meta)
                }
            case .failure(_):
                self.allFiles.accept([])
            }
        }
    }
}
