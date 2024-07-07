//
//  WithdrawalType.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/14.
//

import Foundation

enum WithdrawalType: String, CaseIterable {
    case deleteRecord = "제 기록을 삭제하려고 해요"
    case uncomfortable = "이용이 불편하고 장애가 많아요"
    case anotherService = "타 서비스의 퀄리티가 더 좋아요"
    case lowFrequency = "사용빈도가 낮아요"
    case complaint = "콘텐츠가 불만스러워요"
    case otherReason = "기타 사유"
}
