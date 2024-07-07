//
//  CreateThreadRepositoryType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import Foundation

protocol CreateThreadRepositoryType {
    func createThread(info: RequestCreateThread, completion: @escaping (APIError?) -> Void)
    func searchPlace(place: String, display: Int, completion: @escaping (Result<SearchedPlaces?, APIError>) -> Void)
    func getLocationInfo(lat: Double, long: Double, completion: @escaping (Result<MapInfo?, APIError>) -> Void)
}
