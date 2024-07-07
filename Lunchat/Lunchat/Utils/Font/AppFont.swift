//
//  AppFont.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/16.
//

import UIKit

enum FontName: String {
    case bold = "LINESeedSansKR-Bold"
    case regular = "LINESeedSansKR-Regular"
}

// MARK: - iOS에서 디바이스의 종류 혹은 사이즈 별로 폰트 사이즈를 다이나믹하게 주는 방법을 찾아보기 ( 리팩토링 )

final class AppFont {
    
    static let shared = AppFont()
    
    func getBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: FontName.bold.rawValue, size: size)!
    }
    
    func getRegularFont(size: CGFloat) -> UIFont {
        return UIFont(name: FontName.regular.rawValue, size: size)!
    }
}
