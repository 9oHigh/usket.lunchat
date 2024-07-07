//
//  MenuEnum.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/19.
//

import Foundation

enum MenuType: String, CaseIterable {
    case korean
    case chinese
    case japanese
    case western
    
    var imageName: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .korean:
            return "한식"
        case .chinese:
            return "중식"
        case .japanese:
            return "일식"
        case .western:
            return "양식"
        }
    }
    
    var subTitle: String {
        switch self {
        case .korean:
            return "죽, 국수, 만두, 떡국, 수제비, 구이, 전, 조림..."
        case .chinese:
            return "짜장면, 짬뽕, 팔보채, 양장피, 유산슬, 우동, 마라탕..."
        case .japanese:
            return "소바, 우동, 라멘, 초밥, 오코노미야키, 테판야키..."
        case .western:
            return "파스타, 스테이크, 피자, 샐러드, 햄버거, 샌드위치..."
        }
    }
}
