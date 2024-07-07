//
//  WithdrawalTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/14.
//

import UIKit

final class WithdrawalTableViewCell: UITableViewCell {
    
    static let identifier = "WithdrawalTableViewCell"
    private let clickedImageView = UIImageView(image: UIImage(named: "notClicked"))
    private let reasonLabel = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clickedImageView.image = UIImage(named: "notClicked")
        reasonLabel.textColor = AppColor.grayText.color
        contentView.backgroundColor = AppColor.white.color
    }
    
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
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20))
    }
    
    func setDataSource(_ text: String) {
        reasonLabel.text = text
    }
    
    func setClicked() {
        contentView.backgroundColor = AppColor.purple.color
        reasonLabel.textColor = AppColor.white.color
        clickedImageView.image = UIImage(named: "clicked")
    }
    
    func setNotClicked() {
        contentView.backgroundColor = AppColor.white.color
        reasonLabel.textColor = AppColor.grayText.color
        clickedImageView.image = UIImage(named: "notClicked")
    }
    
    private func setConfig() {
        selectionStyle = .none
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColor.textViewBorder.color.cgColor
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        reasonLabel.textColor = AppColor.grayText.color
        reasonLabel.font = AppFont.shared.getBoldFont(size: 18)
    }
    
    private func setUI() {
        contentView.addSubview(clickedImageView)
        contentView.addSubview(reasonLabel)
    }
    
    private func setConstraint() {
        clickedImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
        }
        
        reasonLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(clickedImageView.snp.trailing).offset(10)
        }
    }
}

