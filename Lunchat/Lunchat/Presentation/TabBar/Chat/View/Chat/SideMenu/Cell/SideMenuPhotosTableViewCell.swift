//
//  SideMenuPhotosCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/10.
//

import UIKit

protocol DetailPhotoDelegate: AnyObject {
    func showDetailPhoto(photoUrl: String, date: String)
}

final class SideMenuPhotosTableViewCell: UITableViewCell {
    
    static let identifier = "SideMenuPhotosTableViewCell"
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    private var files: [FileInfo]?
    weak var detailPhotoDelegate: DetailPhotoDelegate?
    
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
        self.files = nil
    }
    
    func setDataSource(files: [FileInfo]) {
        self.files = files
        self.collectionView.reloadData()
    }
    
    private func setConfig() {
        selectionStyle = .none
        collectionView.backgroundColor = AppColor.white.color
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "SideMenuPhotoCollectionViewCell")
    }
    
    private func setUI() {
        contentView.addSubview(collectionView)
    }
    
    private func setConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SideMenuPhotosTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuPhotoCollectionViewCell.identifier, for: indexPath) as? SideMenuPhotoCollectionViewCell {
            if let fileUrl = files?[indexPath.row].fileURL {
                cell.setImage(with: URL(string: fileUrl))
                return cell
            }
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = ((collectionView.frame.width - 3 * 2) / 3).rounded(.down)
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let fileUrl = files?[indexPath.row].fileURL, let date = files?[indexPath.row].createdAt {
            detailPhotoDelegate?.showDetailPhoto(photoUrl: fileUrl, date: date)
        }
    }
}
