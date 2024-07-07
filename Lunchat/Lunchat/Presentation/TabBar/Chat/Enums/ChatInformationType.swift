//
//  ChatInformationType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/24.
//

import Foundation

enum ChatInformationType {
    case closed
    case caution
    
    var title: String {
        switch self {
        case .closed:
            return "대화가 종료된 방입니다."
        case .caution:
            return "상대를 모욕하는 언어를 삼가 주세요."
        }
    }
}
