//
//  SearchRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation

protocol SearchRepositoryType: AnyObject {
    func searchPlace(place: String, display: Int, completion: @escaping (Result<SearchedPlaces?, APIError>) -> Void)
    func searchUser(page: Int, take: Int, nickname: String, completion: @escaping (Result<SearchedUsers?, APIError>) -> Void )    
    func searchAppointment(page: Int, take: Int, keyword: String, option: String, completion: @escaping (Result<Appointments?, APIError>) -> Void)
}
