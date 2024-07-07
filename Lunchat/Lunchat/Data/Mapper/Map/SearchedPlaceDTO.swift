//
//  SearchedPlaceDTO.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation

typealias SearchedPlacesDTO = [SearchedPlaceDTO]
typealias MapInfosDTO = [MapInfoDTO]

struct SearchedPlaceDTO: Decodable {
    let title, address, roadAddress: String
    let latitude: String
    let longitude: String
}

struct MapInfoDTO: Decodable {
    let title: String
    let address: String
    let roadAddress: String
}

extension SearchedPlaceDTO {
    func toObject() -> SearchedPlace {
        return .init(title: title, address: address, roadAddress: roadAddress, latitude: Double(latitude)!, longitude: Double(longitude)!)
    }
}

extension MapInfoDTO {
    func toMapInfo() -> MapInfo {
        return .init(title: title, address: address, roadAddress: roadAddress)
    }
}
