//
//  TimeInfoView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/04.
//

import UIKit

final class TimeInfoView: UIView {
    
    private let timeLabel = UILabel()
    private let checkImageView = UIImageView(image: UIImage(named: "unCheck"))
    private let bottomLine = UIView()
    private var appointmentDate = Date()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        timeLabel.font = AppFont.shared.getRegularFont(size: 16)
        timeLabel.textColor = AppColor.grayText.color
        timeLabel.numberOfLines = 1
        
        checkImageView.contentMode = .scaleAspectFill
        
        bottomLine.backgroundColor = AppColor.grayText.color
    }
    
    private func setUI() {
        addSubview(timeLabel)
        addSubview(checkImageView)
        addSubview(bottomLine)
    }
    
    private func setConstraint() {
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setActive() {
        self.timeLabel.font = AppFont.shared.getBoldFont(size: 16)
        self.timeLabel.textColor = AppColor.purple.color
        self.checkImageView.image = UIImage(named: "check")
        self.bottomLine.backgroundColor = AppColor.purple.color
    }
    
    func setInActive() {
        self.timeLabel.font = AppFont.shared.getRegularFont(size: 16)
        self.timeLabel.textColor = AppColor.grayText.color
        self.checkImageView.image = UIImage(named: "unCheck")
        self.bottomLine.backgroundColor = AppColor.grayText.color
    }
    
    func setText(date: Date) {
        self.timeLabel.text = date.toCreateAppointmentTime
        self.appointmentDate = date
    }
    
    func getDate() -> Date {
        return appointmentDate
    }
}

