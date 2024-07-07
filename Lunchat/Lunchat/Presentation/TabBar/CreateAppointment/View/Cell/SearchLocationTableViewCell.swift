//
//  SearchLocationTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/06.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchLocationTableViewCell: UITableViewCell {
    
    static let identifier = "SearchLocationTableViewCell"
    private let addressLabel = UILabel()
    private let roadAddressLabel = UILabel()
    private var searchedPlace: SearchedPlace?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.searchedPlace = nil
        setConfig()
    }
    
    func setDataSource(searchedPlace: SearchedPlace) {
        self.searchedPlace = searchedPlace
        
        self.addressLabel.text = searchedPlace.title
        self.roadAddressLabel.text = searchedPlace.roadAddress
    }
    
    func setActive() {
        addressLabel.textColor = AppColor.white.color
        roadAddressLabel.textColor = AppColor.white.color
        backgroundColor = AppColor.purple.color
    }
    
    func setInActive() {
        addressLabel.textColor = AppColor.black.color
        roadAddressLabel.textColor = AppColor.black.color
        backgroundColor = AppColor.white.color
    }
    
    func getPlace() -> SearchedPlace? {
        return self.searchedPlace
    }
    
    private func setConfig() {
        selectionStyle = .none

        addressLabel.font = AppFont.shared.getBoldFont(size: 15)
        addressLabel.textColor = AppColor.black.color
        addressLabel.numberOfLines = 1
        
        roadAddressLabel.font = AppFont.shared.getRegularFont(size: 9)
        roadAddressLabel.textColor = AppColor.grayText.color
        roadAddressLabel.numberOfLines = 1
    }
    
    private func setUI() {
        addSubview(addressLabel)
        addSubview(roadAddressLabel)
    }
    
    private func setConstraint() {
        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(32)
        }
        
        roadAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
            make.leading.equalTo(32)
        }
    }
}
