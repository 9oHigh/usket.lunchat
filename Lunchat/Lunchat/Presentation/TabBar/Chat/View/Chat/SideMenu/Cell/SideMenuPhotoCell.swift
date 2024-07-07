//
//  SideMenuPhotoCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/07.
//

import UIKit

final class SideMenuPhotoCell: UICollectionViewCell {
    
    static let identifier = "SideMenuPhotoCell"
    private let photoImageView = UIImageView()
    
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
        photoImageView.image = nil
    }
    
    func setDataSource(file: FileInfo) {
        self.photoImageView.loadImageFromUrl(url: URL(string: file.fileURL), isDownSampling: false)
    }
    
    private func setConfig() {
        photoImageView.contentMode = .scaleAspectFill
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    private func setUI() {
        contentView.addSubview(photoImageView)
    }
    
    private func setConstraint() {
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
