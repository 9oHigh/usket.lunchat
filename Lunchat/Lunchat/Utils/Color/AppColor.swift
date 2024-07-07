//
//  ColorManager.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/16.
//

import UIKit

enum AppColor {
    case black
    case white
    case red
    case purple
    case headerPurple
    case headerWhite
    case hashtag
    case inActive
    case grayText
    case deepGrayText
    case thinGrayText
    case thinGrayBackground
    case textField
    case textFieldBorder
    case textViewBorder
    case bio
    case appointmentInfo
    case chatDate
    
    var color : UIColor {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .red:
            return UIColor(hex: "#BF1414")
        case .purple:
            return UIColor(hex: "#8158D8").withAlphaComponent(0.9)
        case .headerPurple:
            return UIColor(hex: "#8158D8")
        case .headerWhite:
            return UIColor(hex: "#B280F5")
        case .hashtag:
            return UIColor(hex: "#3E78CEE5").withAlphaComponent(0.9)
        case .inActive:
            return UIColor(hex: "#DEDEDE")
        case .grayText:
            return UIColor(hex: "#858597")
        case .deepGrayText:
            return UIColor(hex: "#6F7077")
        case .thinGrayText:
            return UIColor(hex: "#A2A2A2")
        case .thinGrayBackground:
            return UIColor(hex: "F5F5F5")
        case .textField:
            return UIColor(hex: "#D9D9D9").withAlphaComponent(0.38)
        case .textFieldBorder:
            return UIColor(hex: "#C2C2C2")
        case .textViewBorder:
            return UIColor(hex: "#F5F5F5")
        case .bio:
            return UIColor(hex: "#50505E")
        case .appointmentInfo:
            return UIColor(hex: "#000000").withAlphaComponent(0.6)
        case .chatDate:
            return UIColor(hex: "#EDEDED")
        }
    }
}
