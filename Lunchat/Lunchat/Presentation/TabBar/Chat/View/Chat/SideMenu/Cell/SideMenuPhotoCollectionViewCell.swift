//
//  SideMenuPhotoCollectionViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/10.
//

import UIKit

final class SideMenuPhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SideMenuPhotoCollectionViewCell"
    private let imageView = UIImageView()
    
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
        self.imageView.image = nil
    }
    
    private func setConfig() {
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    private func setUI() {
        addSubview(imageView)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setImage(with url: URL?) {
        imageView.loadImageFromUrl(url: url, isDownSampling: false)
    }
}
