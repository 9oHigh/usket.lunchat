//
//  PurchaseViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/05.
//

import UIKit

final class PurchaseCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PurchaseViewCell"
    
    private let ticketImageView = UIImageView()
    private let ticketLabel = UILabel()
    private let priceButtn = LunchatButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDataSource(ticketCount: String, cost: String, isNotch: Bool) {
        ticketImageView.image = UIImage(named: "ticket\(ticketCount)")
        ticketLabel.text = "\(ticketCount)회권"
        priceButtn.setTitle("\(cost)원", for: .normal)
        isNotch ? priceButtn.setFont(of: 20) : priceButtn.setFont(of: 14)
    }
    
    private func setConfig() {
        backgroundView = UIImageView(image: UIImage(named: "ticketBackground"))
        ticketImageView.contentMode = .scaleAspectFit
        
        ticketLabel.font = AppFont.shared.getBoldFont(size: 14)
        ticketLabel.textColor = AppColor.black.color
        ticketLabel.textAlignment = .center
        
        priceButtn.setFont(of: 20)
        priceButtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        priceButtn.layer.cornerRadius = 10
        priceButtn.isUserInteractionEnabled = false
    }
    
    private func setUI() {
        addSubview(ticketImageView)
        addSubview(ticketLabel)
        addSubview(priceButtn)
    }
    
    private func setConstraint() {
        
        ticketImageView.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.915)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        ticketLabel.snp.makeConstraints { make in
            make.top.equalTo(ticketImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        priceButtn.snp.makeConstraints { make in
            make.top.equalTo(ticketLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9375)
            make.bottom.equalToSuperview()
        }
    }
}
