//
//  String+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 3/25/24.
//

import Foundation

extension String {
    
    var toAppointmentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "ko_KR")
        let date = dateFormatter.date(from: self)!
        return date.toAppointmentTime
    }
    
    var toScheduleTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "ko_KR")
        let date = dateFormatter.date(from: self)!
        return date.toScheduleTime
    }
    
    var toPhotoTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "ko_KR")
        let date = dateFormatter.date(from: self)!
        return date.toPhotoTime
    }
    
    func toChatTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            return dateFormatter.string(from: date)
        } else {
            return "알 수 없음"
        }
    }
    
    func toDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: self) ?? Date()
    }
    
    var timeAgo: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date, to: Date())
            
            if let hours = components.hour, hours < 24 {
                return "\(hours)시간 전"
            } else {
                let days = calendar.dateComponents([.day], from: date, to: Date())
                return "\(days.day ?? 0)일 전"
            }
        } else {
            return "알 수 없음"
        }
    }
    
    var daysAgo: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = dateFormatter.date(from: self)
        else {
            return "알 수 없음"
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        if let days = components.day {
            switch days {
            case 0:
                return "오늘"
            case 1:
                return "어제"
            case 2...10:
                return "\(days)일 전"
            default:
                return "오래전"
            }
        }
        
        return "알 수 없음"
    }
}
