//
//  HomeCellButtonType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/19.
//

import Foundation

enum HomeCellButtonType: String {
    case participate
    case exit
    case cancel
    
    var imageName: String {
        return self.rawValue + "Appointment"
    }
}
