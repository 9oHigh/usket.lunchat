//
//  SearchedPlace.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/22.
//

import Foundation

typealias SearchedPlaces = [SearchedPlace]

struct SearchedPlace {
    let title: String
    let address: String
    let roadAddress: String
    let latitude: Double
    let longitude: Double
}
