//
//  HashTagCollectionViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/09.
//

import UIKit

final class HashTagCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HashTagCollectionViewCell"
    private let hashTagLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDataSource(hashtag: String) {
        self.hashTagLabel.text = "#\(hashtag)"
    }
    
    func getIntrinsicWidth() -> CGFloat {
        return self.hashTagLabel.intrinsicContentSize.width
    }
    
    private func setConfig() {
        hashTagLabel.font = AppFont.shared.getBoldFont(size: 14)
        hashTagLabel.textColor = AppColor.hashtag.color
    }
    
    private func setUI() {
        contentView.addSubview(hashTagLabel)
    }
    
    private func setConstraint() {
        hashTagLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
