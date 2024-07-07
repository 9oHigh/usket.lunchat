//
//  TimePickerView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/04.
//

import UIKit
import RxSwift
import RxCocoa

class CreateAppointmentTimePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let dateObservable = PublishSubject<Date>()
    private let days = ["오늘", "내일"]
    private let hours = Array(0...23)
    private let minutes = Array(stride(from: 0, through: 50, by: 10))
    
    var selectedDate: Date {
        let selectedDayRow = self.selectedRow(inComponent: 0)
        let selectedHourRow = self.selectedRow(inComponent: 1)
        let selectedMinuteRow = self.selectedRow(inComponent: 2)
        
        var calendar = Calendar.current
        var components = DateComponents()
        calendar.locale = .autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .autoupdatingCurrent
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        
        if selectedDayRow == 0 {
            components.day = calendar.component(.day, from: Date())
            components.month = calendar.component(.month, from: Date())
            components.year = calendar.component(.year, from: Date())
            components.hour = hours[selectedHourRow]
        } else {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            components.day = calendar.component(.day, from: tomorrow)
            components.month = calendar.component(.month, from: tomorrow)
            components.year = calendar.component(.year, from: tomorrow)
            components.hour = hours[selectedHourRow]
        }
        
        components.minute = minutes[selectedMinuteRow]
        
        return calendar.date(from: components) ?? Date()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
        setCurrentTime()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setCurrentTime() {
        let currentDate = Date()
        let calendar = Calendar.current
        var currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        selectRow(0, inComponent: 0, animated: true)
        
        var roundedMinute = Int(ceil(Double(currentMinute) / 10.0)) * 10
        
        if roundedMinute >= 60 {
            roundedMinute = 0
            currentHour += 1
            if currentHour == 24 {
                currentHour = 0
                selectRow(0, inComponent: 1, animated: true)
            }
        }
        
        selectRow(currentHour, inComponent: 1, animated: true)
        let minuteRow = minutes.firstIndex(of: roundedMinute) ?? 0
        selectRow(minuteRow, inComponent: 2, animated: true)
        
        reloadAllComponents()
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return days.count
        } else if component == 1 {
            return hours.count
        } else {
            return minutes.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let reusedView = view as? UILabel {
            label = reusedView
        } else {
            label = UILabel()
        }
        
        let boldFont = AppFont.shared.getBoldFont(size: 30)
        let regularFont = AppFont.shared.getBoldFont(size: 20)
        
        if component == 0 {
            label.text = days[row]
        } else if component == 1 {
            label.text = String(format: "%d", hours[row])
        } else {
            label.text = String(format: "%02d", minutes[row])
        }
        
        label.font = pickerView.selectedRow(inComponent: component) == row ? boldFont : regularFont
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(component)
        dateObservable.onNext(selectedDate)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 100.0
        } else {
            return 60.0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = pickerView.delegate?.pickerView?(pickerView, titleForRow: row, forComponent: component) ?? ""
        let boldFont = AppFont.shared.getBoldFont(size: 30)
        let regularFont = AppFont.shared.getBoldFont(size: 20)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: pickerView.selectedRow(inComponent: component) == row ? boldFont : regularFont]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func getDateObservable() -> PublishSubject<Date> {
        return self.dateObservable
    }
}
