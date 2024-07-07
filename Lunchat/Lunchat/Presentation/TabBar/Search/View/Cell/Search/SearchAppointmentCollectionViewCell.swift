//
//  SearchAppointmentCollectionViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/15.
//

import UIKit
import RxSwift

final class SearchAppointmentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SearchAppointmentCollectionViewCell"
    
    private let photoImageView = UIImageView()
    private let remainTimeView = UIView()
    private let remainTimeLabel = UILabel()
    private var countdownTimer: Timer?
    
    private let organizerImageView = UIImageView()
    private let organizerNicknameLabel = UILabel()
    private let organizerBioLabel = UILabel()
    
    private let titleLabel = UILabel()
    private let hashTagLabel = UILabel()
    private let addressLabel = UILabel()
    private let appointmentScheduleLabel = UILabel()
    
    private var appointmentId: String?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
        self.organizerImageView.image = nil
        self.organizerNicknameLabel.text = nil
        self.titleLabel.text = nil
        self.hashTagLabel.text = nil
        self.addressLabel.text = nil
        self.appointmentScheduleLabel.text = nil
        self.appointmentId = nil
        self.disposeBag = DisposeBag()
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    func setDataSource(appointment: Appointment) {
        self.photoImageView.loadImageFromUrl(url: URL(string: appointment.photoUrl))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "ko_KR")
        
        if let appointmentTime = dateFormatter.date(from: appointment.scheduledAt) {
            let currentYear = Calendar.current.component(.year, from: Date())
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: appointmentTime)
            
            if let appointmentYear = components.year, appointmentYear > currentYear {
                components.year = currentYear + 1
            } else {
                components.year = currentYear
            }
            
            if let adjustedAppointmentTime = Calendar.current.date(from: components) {
                let remainingTime = adjustedAppointmentTime.timeIntervalSince(Date())
                startCountdownTimer(endTime: remainingTime)
            }
        }
        
        self.organizerImageView.loadImageFromUrl(url: URL(string: appointment.organizerProfilePicture))
        self.organizerNicknameLabel.text = appointment.organizerNickname
        self.organizerBioLabel.text = appointment.organizerBio
        self.titleLabel.text = appointment.title
        
        var hashTagString: String = ""
        appointment.hashTags?.forEach({ hashtag in
            hashTagString.append("#\(hashtag) ")
        })
        
        if hashTagString.isEmpty {
            hashTagString.append("#런챗")
        }
        
        self.hashTagLabel.text = hashTagString
        self.addressLabel.text = appointment.placeArea
        self.appointmentScheduleLabel.text = appointment.scheduledAt.toScheduleTime
        self.appointmentId = appointment.id
    }
    
    func updateCountdownLabel(with remainingTime: TimeInterval) {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        
        let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        remainTimeLabel.text = formattedTime
    }
    
    func startCountdownTimer(endTime: TimeInterval) {
        let currentTimeInterval = Date().timeIntervalSinceReferenceDate
        let endTimeInterval = currentTimeInterval + endTime
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let remainingTime = max(endTimeInterval - Date().timeIntervalSinceReferenceDate, 0)
            
            self.updateCountdownLabel(with: remainingTime)
            
            if remainingTime <= 0 {
                self.countdownTimer?.invalidate()
                self.countdownTimer = nil
            }
        }
    }
    
    func getAppointmentId() -> String? {
        return self.appointmentId
    }
    
    private func setConfig() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        contentView.backgroundColor = AppColor.white.color
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.masksToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        
        remainTimeView.backgroundColor = AppColor.black.color.withAlphaComponent(0.6)
        remainTimeView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        remainTimeView.layer.cornerRadius = 5
        remainTimeView.layer.masksToBounds = true
        
        remainTimeLabel.font = AppFont.shared.getBoldFont(size: 15)
        remainTimeLabel.textColor = AppColor.white.color
        remainTimeLabel.backgroundColor = .clear
        remainTimeLabel.textAlignment = .center
        remainTimeLabel.text = "00:00:00"
        
        organizerImageView.layer.cornerRadius = 5
        organizerImageView.layer.masksToBounds = true
        organizerImageView.contentMode = .scaleAspectFill
        
        organizerNicknameLabel.font = AppFont.shared.getBoldFont(size: 8)
        organizerNicknameLabel.textColor = AppColor.black.color
        organizerNicknameLabel.numberOfLines = 1
        
        organizerBioLabel.font = AppFont.shared.getBoldFont(size: 8)
        organizerBioLabel.textColor = AppColor.grayText.color
        organizerBioLabel.numberOfLines = 1
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 12)
        titleLabel.textColor = AppColor.black.color
        titleLabel.numberOfLines = 1
        
        hashTagLabel.font = AppFont.shared.getBoldFont(size: 9)
        hashTagLabel.textColor = AppColor.hashtag.color
        
        addressLabel.font = AppFont.shared.getBoldFont(size: 9)
        addressLabel.textColor = AppColor.black.color
        
        appointmentScheduleLabel.font = AppFont.shared.getRegularFont(size: 9)
        appointmentScheduleLabel.textColor = AppColor.black.color
    }
    
    private func setUI() {
        contentView.addSubview(photoImageView)
        photoImageView.addSubview(remainTimeView)
        remainTimeView.addSubview(remainTimeLabel)
        contentView.addSubview(organizerImageView)
        contentView.addSubview(organizerNicknameLabel)
        contentView.addSubview(organizerBioLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(hashTagLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(appointmentScheduleLabel)
    }
    
    private func setConstraint() {
        photoImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(4)
            make.trailing.equalTo(-4)
            make.height.equalToSuperview().multipliedBy(0.55)
        }
        
        remainTimeView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.21)
        }
        
        remainTimeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        organizerImageView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(4)
            make.leading.equalTo(4)
            make.width.height.equalTo(28)
        }
        
        organizerNicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(organizerImageView.snp.trailing).offset(4)
            make.top.equalTo(organizerImageView.snp.top).offset(4)
            make.trailing.equalTo(-16)
        }
        
        organizerBioLabel.snp.makeConstraints { make in
            make.leading.equalTo(organizerImageView.snp.trailing).offset(4)
            make.top.equalTo(organizerNicknameLabel.snp.bottom).offset(2)
            make.trailing.equalTo(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(organizerImageView.snp.bottom).offset(5)
            make.leading.equalTo(4)
            make.trailing.equalTo(-4)
        }
        
        hashTagLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(4)
            make.trailing.equalTo(-4)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(hashTagLabel.snp.bottom).offset(4)
            make.leading.equalTo(4)
        }
        
        appointmentScheduleLabel.snp.makeConstraints { make in
            make.leading.equalTo(addressLabel.snp.trailing).offset(4)
            make.trailing.equalTo(-4)
            make.centerY.equalTo(addressLabel.snp.centerY)
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
