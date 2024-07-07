//
//  TicketType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/16.
//

import Foundation

enum TicketType: Int, CaseIterable {
    case ticket1 = 1
    case ticket3 = 3
    case ticket5 = 5
    case ticket10 = 10
    case ticket20 = 20
    case ticket30 = 30
    
    var price: String {
        switch self {
        case .ticket1:
            return "990"
        case .ticket3:
            return "2,500"
        case .ticket5:
            return "4,500"
        case .ticket10:
            return "7,500"
        case .ticket20:
            return "13,500"
        case .ticket30:
            return "17,500"
        }
    }
    
    var imageName: String {
        switch self {
        case .ticket1:
            return "ticket1"
        case .ticket3:
            return "ticket3"
        case .ticket5:
            return "ticket5"
        case .ticket10:
            return "ticket10"
        case .ticket20:
            return "ticket20"
        case .ticket30:
            return "ticket30"
        }
    }
    
    var indexPath: Int {
        switch self {
        case .ticket1:
            return 0
        case .ticket3:
            return 1
        case .ticket5:
            return 2
        case .ticket10:
            return 3
        case .ticket20:
            return 4
        case .ticket30:
            return 5
        }
    }
}
