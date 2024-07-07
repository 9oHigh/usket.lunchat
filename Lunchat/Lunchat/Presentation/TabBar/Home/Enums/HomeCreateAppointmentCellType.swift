//
//  HomeCreateAppointmentCellType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/20.
//

import Foundation

enum HomeCreateAppointmentCellType {
    case empty
    case recommend
    
    var title: String {
        switch self {
        case .empty:
            return "보여드릴 밥약이 없어요!"
        case .recommend:
            return "마음에 드는 밥약이 없으신가요?"
        }
    }
    
    var subTitle: String {
        switch self {
        case .empty:
            return "지금 보여드릴 추천 밥약이 존재하지 않아요.\n직접 만들어보시는건 어떨까요?"
        case .recommend:
            return "아래의 버튼을 눌러\n밥약 생성을 통해 다양한 사람들과 만나 보세요!"
        }
    }
    
    var imageName: String {
        switch self {
        case .empty:
            return "emptyAppointment"
        case .recommend:
            return "recommendAppointment"
        }
    }
}
