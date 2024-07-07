//
//  CreateThreadUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import Foundation
import RxSwift

final class CreateThreadUseCase {
    
    private let createThreadRepository: CreateThreadRepositoryType
    let isCreated = PublishSubject<Bool>()
    let places = PublishSubject<SearchedPlaces?>()
    let mapInfo = PublishSubject<MapInfo?>()
    
    init(createThreadRepository: CreateThreadRepositoryType) {
        self.createThreadRepository = createThreadRepository
    }
    
    func searchPlace(place: String, display: Int = 5) {
        
        createThreadRepository.searchPlace(place: place, display: display) { [weak self] result in
            switch result {
            case .success(let places):
                if let places = places {
                    self?.places.onNext(places)
                } else {
                    self?.places.onNext(nil)
                }
            case .failure(_):
                self?.places.onNext(nil)
            }
        }
    }
    
    func createThread(info: RequestCreateThread) {
        
        createThreadRepository.createThread(info: info, completion: { [weak self] error in
            if error != nil {
                self?.isCreated.onNext(false)
            } else {
                self?.isCreated.onNext(true)
            }
        })
    }
    
    func getLocationInfo(lat: Double, long: Double) {
        
        createThreadRepository.getLocationInfo(lat: lat, long: long) { [weak self] result in
            switch result {
            case .success(let info):
                if let info = info {
                    self?.mapInfo.onNext(info)
                } else {
                    self?.mapInfo.onNext(nil)
                }
            case .failure(_):
                self?.mapInfo.onNext(nil)
            }
        }
    }
}
