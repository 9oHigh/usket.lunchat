//
//  SearchUseCase.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation
import RxSwift

final class SearchUseCase {
    
    private let searchRespository: SearchRepositoryType
    let places = PublishSubject<SearchedPlaces?>()
    let users = PublishSubject<SearchedUsers?>()
    let appointments = PublishSubject<Appointments?>()
    
    init(searchRespository: SearchRepositoryType) {
        self.searchRespository = searchRespository
    }
    
    func searchPlace(place: String, display: Int = 5) {
        
        searchRespository.searchPlace(place: place, display: display) { [weak self] result in
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
    
    func searchUser(page: Int, take: Int, nickname: String, completion: @escaping () -> Void = { }) {
        
        searchRespository.searchUser(page: page, take: take, nickname: nickname) { [weak self] result in
            switch result {
            case .success(let users):
                if let users = users {
                    self?.users.onNext(users)
                    completion()
                } else {
                    self?.users.onNext(nil)
                }
            case .failure(_):
                self?.users.onNext(nil)
            }
        }
    }
    
    func searchAppointment(page: Int, take: Int, keyword: String = "", option: String = "", completion: @escaping () -> Void = {}) {
        
        searchRespository.searchAppointment(page: page, take: take, keyword: keyword, option: option) { [weak self] result in
            switch result {
            case .success(let appointments):
                if let appointments = appointments {
                    self?.appointments.onNext(appointments)
                    completion()
                } else {
                    self?.appointments.onNext(nil)
                }
            case .failure(_):
                self?.appointments.onNext(nil)
            }
        }
    }
}
