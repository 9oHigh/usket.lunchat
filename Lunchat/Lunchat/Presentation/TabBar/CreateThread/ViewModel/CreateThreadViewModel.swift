//
//  CreateThreadViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateThreadViewModel {
    
    let searchedPlaces = PublishSubject<SearchedPlaces?>()
    let mapInfo = PublishSubject<MapInfo?>()
    
    private var fileUrl: String?
    private var restaurantTitle: String?
    private var chosenPlace: SearchedPlace?
    
    private let useCase: CreateThreadUseCase
    private let fileUseCase: FileUseCase
    private weak var createThreadViewDelegate: CreateThreadViewDelegate?
    private var disposeBag = DisposeBag()
    
    init(useCase: CreateThreadUseCase, fileUseCase: FileUseCase, delegate: CreateThreadViewDelegate) {
        self.useCase = useCase
        self.fileUseCase = fileUseCase
        self.createThreadViewDelegate = delegate
    }
    
    func setRestaurantTitle(title: String) {
        self.restaurantTitle = title
    }
    
    func getRestaurantTitle() -> String? {
        return self.restaurantTitle
    }
    
    func showMapViewController() {
        if let lat = chosenPlace?.latitude, let long = chosenPlace?.longitude {
            createThreadViewDelegate?.showMapViewController(lat: lat, long: long)
        }
    }
    
    func searchPlaces(place: String) {
        useCase.searchPlace(place: place)
        
        useCase.places.subscribe(onNext: { [weak self] places in
            if let searchedPlaces = places {
                self?.searchedPlaces.onNext(searchedPlaces)
            } else {
                self?.searchedPlaces.onNext(nil)
                self?.createThreadViewDelegate?.showInAccessableLocationView()
            }
        })
        .disposed(by: disposeBag)
    }
    
    func choosePlace(place: SearchedPlace) {
        self.chosenPlace = place
    }
    
    func getChosenPlace() -> SearchedPlace? {
        return self.chosenPlace
    }
    
    func getAddress(lat: Double, long: Double) {
        useCase.getLocationInfo(lat: lat, long: long)
        
        useCase.mapInfo.subscribe(onNext: { [weak self] info in
            if let mapInfo = info {
                self?.mapInfo.onNext(mapInfo)
                self?.choosePlace(place: SearchedPlace(title: mapInfo.title, address: mapInfo.address, roadAddress: mapInfo.roadAddress, latitude: lat, longitude: long))
            } else {
                self?.mapInfo.onNext(nil)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func showMapChosenFailure() {
        createThreadViewDelegate?.showMapChosenFailure()
    }
    
    func showInfoViewController() {
        if let chosenPlace = chosenPlace {
            createThreadViewDelegate?.showInfoViewController(locationInfo: chosenPlace)
        } else {
            createThreadViewDelegate?.showMapChosenFailure()
        }
    }
    
    func subscribeFileUrl() {
        fileUseCase.presignedUrl.subscribe(onNext: { [weak self] url in
            if let url = url {
                self?.fileUrl = url
            } else {
                self?.createThreadViewDelegate?.showPhotoUploadFailure()
            }
        })
        .disposed(by: disposeBag)
    }
    
    func postToImagePresignedUrl(image: UIImage, imageType: String) {
        let fileExt = FileExt(fileExt: imageType)
        fileUseCase.createPresignedUrl(image: image, imageType: fileExt)
    }
    
    func subscribeIsCreated(completion: @escaping () -> Void) {
        useCase.isCreated.subscribe(onNext: { [weak self] isCreated in
            if isCreated {
                self?.createThreadViewDelegate?.showCreateThreadSuccess()
            } else {
                self?.createThreadViewDelegate?.showCreateThreadFailure()
            }
            completion()
        })
        .disposed(by: disposeBag)
    }
    
    func createThread(title: String, content: String) {
        
        if let createThread = createThreadViewDelegate?.getCreateThreadParm() {
            let request = RequestCreateThread(fileUrl: fileUrl, title: title, content: content, placeTitle: createThread.placeTitle, placeAddress: createThread.placeAddress, placeRoadAddress: createThread.placeRoadAddress)
            useCase.createThread(info: request)
        }
    }
    
    func finishCoordinator() {
        createThreadViewDelegate?.finishCreateThread()
    }
}
