//
//  Date+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import Foundation

extension Date {
    
    var toAppointmentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 H시 m분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var toScheduleTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d(E) H:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var toCreateAppointmentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일(E) a h시 mm분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var toChatTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var toChatDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 E요일"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var toPhotoTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let str = dateFormatter.string(from: self)
        return str
    }
}
