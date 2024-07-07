//
//  UIColor+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/16.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        var hexWithoutSymbol = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol.remove(at: hexWithoutSymbol.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexWithoutSymbol).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
