//
//  OpenSourceTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/24.
//

import UIKit

final class OpenSourceTableViewCell: UITableViewCell {
    
    static let identifier = "OpenSourceTableViewCell"
    private let titleLabel = UILabel()
    private let urlButton = UIButton()
    private let copyrightLabel = UILabel()
    private let licenseButton = UIButton()
    private let licenseDetailTextView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        urlButton.setTitle("", for: .normal)
        copyrightLabel.text = nil
        licenseButton.setTitle("", for: .normal)
        licenseDetailTextView.text = nil
    }
    
    private func setConfig() {
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        titleLabel.textColor = AppColor.thinGrayText.color
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        
        urlButton.backgroundColor = AppColor.white.color
        
        copyrightLabel.textColor = AppColor.thinGrayText.color
        copyrightLabel.font = AppFont.shared.getBoldFont(size: 12)
        
        licenseButton.setTitleColor(AppColor.black.color, for: .normal)
        licenseButton.titleLabel?.font = AppFont.shared.getBoldFont(size: 12)
        
        licenseDetailTextView.isHidden = true
        licenseDetailTextView.isEditable = false
        licenseDetailTextView.backgroundColor = AppColor.white.color
        licenseDetailTextView.layer.borderColor = AppColor.thinGrayText.color.cgColor
        licenseDetailTextView.layer.borderWidth = 0.5
        licenseDetailTextView.layer.cornerRadius = 5
    }
    
    private func setUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(urlButton)
        contentView.addSubview(copyrightLabel)
        contentView.addSubview(licenseButton)
        contentView.addSubview(licenseDetailTextView)
    }
    
    private func setConstraint() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(12)
        }
        
        urlButton.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(16)
        }
        
        copyrightLabel.snp.remakeConstraints { make in
            make.top.equalTo(urlButton.snp.bottom)
            make.leading.equalTo(16)
        }
        
        licenseButton.snp.remakeConstraints { make in
            make.top.equalTo(copyrightLabel.snp.bottom)
            make.leading.equalTo(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setDetailConstraint() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(12)
        }
        
        urlButton.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(16)
        }
        
        copyrightLabel.snp.remakeConstraints { make in
            make.top.equalTo(urlButton.snp.bottom)
            make.leading.equalTo(16)
        }
        
        licenseButton.snp.remakeConstraints { make in
            make.top.equalTo(copyrightLabel.snp.bottom)
            make.leading.equalTo(16)
        }
        
        licenseDetailTextView.snp.remakeConstraints { make in
            make.top.equalTo(licenseButton.snp.bottom).offset(8)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(135)
        }
    }
    
    func setOpenSourceInfo(_ type: OpenSourceType) {
        guard let urlString = type.url?.absoluteString else { return }
        
        let underlineAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: AppColor.purple.color, NSAttributedString.Key.font: AppFont.shared.getBoldFont(size: 12)]
        let underlineAttributedString = NSAttributedString(string: urlString, attributes: underlineAttribute)
        urlButton.setAttributedTitle(underlineAttributedString, for: .normal)
        
        titleLabel.text = "* \(type.rawValue)"
        copyrightLabel.text = type.copyright
        licenseButton.setTitle(type.lisense, for: .normal)
        licenseDetailTextView.text = type.licenseDetail
    }
}
