//
//  PurchaseHistroyViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import UIKit

final class PurchaseHistoryViewCell: UITableViewCell {
    
    static let identifier = "PurchaseHistoryViewCell"
    
    private let dateLabel = UILabel()
    private let purchaseCountLabel = UILabel()
    private let priceLabel = UILabel()
    private let ticketImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDataSource(date: String, purchaseCount: String, price: String) {
        dateLabel.text = date.toPhotoTime
        
        let countAttributedString = NSMutableAttributedString(string: "구매 \(purchaseCount)개")
        let countRange = NSRange(location: 2, length: countAttributedString.length - 2)
        countAttributedString.addAttribute(.foregroundColor, value: AppColor.black.color, range: countRange)
        purchaseCountLabel.attributedText = countAttributedString
        
        let formattedCurrency = formatCurrency(from: price) ?? "0"
        let priceAttributedString = NSMutableAttributedString(string: "금액 \(formattedCurrency)원")
        let priceRange = NSRange(location: 2, length: priceAttributedString.length - 2)
        priceAttributedString.addAttribute(.foregroundColor, value: AppColor.black.color , range: priceRange)
        priceLabel.attributedText = priceAttributedString
        
        ticketImageView.image = UIImage(named: TicketType(rawValue: Int(purchaseCount)!)!.imageName)
    }

    private func setConfig() {
        
        selectionStyle = .none
        
        dateLabel.font = AppFont.shared.getBoldFont(size: 10)
        dateLabel.textColor = AppColor.thinGrayText.color
        
        purchaseCountLabel.font = AppFont.shared.getBoldFont(size: 13)
        purchaseCountLabel.textColor = AppColor.thinGrayText.color
        
        priceLabel.font = AppFont.shared.getBoldFont(size: 13)
        priceLabel.textColor = AppColor.thinGrayText.color
        
        ticketImageView.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(purchaseCountLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(ticketImageView)
    }
    
    private func setConstraint() {
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.leading.equalTo(12)
        }
        
        purchaseCountLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(-4)
            make.leading.equalTo(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(purchaseCountLabel.snp.bottom).offset(8)
            make.leading.equalTo(12)
            make.bottom.equalTo(-12)
        }
        
        ticketImageView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.trailing.equalTo(-12)
            make.bottom.equalTo(-12)
        }
    }
    
    private func formatCurrency(from numericString: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_KR")

        if let number = formatter.number(from: numericString) {
            return formatter.string(from: number)
        } else {
            return nil
        }
    }
}
