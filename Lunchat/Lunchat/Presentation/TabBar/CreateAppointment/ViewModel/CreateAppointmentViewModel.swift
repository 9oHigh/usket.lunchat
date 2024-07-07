//
//  CreateAppointmentViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/04.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateAppointmentViewModel {

    let searchedPlaces = PublishSubject<SearchedPlaces?>()
    let mapInfo = PublishSubject<MapInfo?>()
    let isCreated = PublishSubject<Bool>()
    private var chosenPlace: SearchedPlace?
    private let useCase: CreateAppointmentUseCase
    private weak var createAppointmentDelegate: CreateAppointmentDelegate?
    private let disposeBag = DisposeBag()
    
    init(useCase: CreateAppointmentUseCase, delegate: CreateAppointmentDelegate?) {
        self.useCase = useCase
        self.createAppointmentDelegate = delegate
    }
    
    func showTimeViewController(menuType: MenuType) {
        createAppointmentDelegate?.showTimeViewController(menuType: menuType)
    }
    
    func showParticipantViewController(date: Date) {
        createAppointmentDelegate?.showParticipiantViewController(date: date)
    }
    
    func showLocationViewController(count: Int) {
        createAppointmentDelegate?.showLocationViewController(count: count)
    }
    
    func showMapViewController() {
        if let lat = self.chosenPlace?.latitude, let long = self.chosenPlace?.longitude {
            createAppointmentDelegate?.showMapViewController(lat: lat, long: long)
        }
    }
    
    func searchPlaces(place: String) {
        useCase.searchPlace(place: place)
        
        useCase.places.subscribe({ [weak self] places in
            if let places = places.element, let searchedPlaces = places {
                self?.searchedPlaces.onNext(searchedPlaces)
            } else {
                self?.searchedPlaces.onNext(nil)
                self?.createAppointmentDelegate?.showInAccessableLocation()
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
        useCase.mapInfo.subscribe({ [weak self] info in
            if let info = info.element, let mapInfo = info {
                self?.mapInfo.onNext(mapInfo)
                self?.choosePlace(place: SearchedPlace(title: mapInfo.title, address: mapInfo.address, roadAddress: mapInfo.roadAddress, latitude: lat, longitude: long))
            } else {
                self?.mapInfo.onNext(nil)
            }
        })
        .disposed(by: disposeBag)
        
        useCase.getLocationInfo(lat: lat, long: long)
    }
    
    func showMapChosenFailure() {
        createAppointmentDelegate?.showMapChosenFailure()
    }
    
    func showInfoViewController() {
        if let chosenPlace = chosenPlace {
            createAppointmentDelegate?.showInfoViewController(locationInfo: chosenPlace)
        } else {
            createAppointmentDelegate?.showMapChosenFailure()
        }
    }
    
    func showCreateAppointment(title: String, hashtag: [String]) {
        if var request = createAppointmentDelegate?.getAppointment() {
            request.title = title
            request.hashTags = hashtag
            createAppointmentDelegate?.showAppointmentCreate(request: request, viewModel: self)
        }
    }
    
    func createAppointment(request: RequestCreateAppointment) {
        
        useCase.createAppointment(appointmentInfo: request)

        useCase.appointment.subscribe({ [weak self] appointment in
            if let appointment = appointment.element, let _ = appointment {
                self?.isCreated.onNext(true)
            } else {
                self?.isCreated.onNext(false)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func extractHashtags(from text: String) -> [String] {
        let hashtagRegex = try! NSRegularExpression(pattern: "#\\w+", options: [])
        let matches = hashtagRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        guard !matches.isEmpty else {
            return []
        }
        
        let hashtags = matches.map { match -> String in
            let range = Range(match.range, in: text)!
            var returnText = String(text[range])
            returnText.remove(at: returnText.startIndex)
            return returnText
        }
        
        return hashtags
    }
    
    func finishCoordinator() {
        createAppointmentDelegate?.finishCoordinator()
    }
}
