//
//  SideMenuPhotoView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/07.
//

import UIKit
import RxSwift

final class SideMenuPhotoView: UIView {
    
    private let photoImageView = UIImageView(image: UIImage(named: "picture"))
    private let photoTitle = UILabel()
    private let toDetailImageButton = UIButton()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    private let bottomLine = UIView()
    private var files: [FileInfo]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDataSource(files: [FileInfo]) {
        self.files = files
        self.collectionView.reloadData()
    }
    
    private func setConfig() {
        backgroundColor = AppColor.white.color
        photoImageView.contentMode = .scaleAspectFill
        
        photoTitle.text = "사진"
        photoTitle.font = AppFont.shared.getBoldFont(size: 12)
        photoTitle.textColor = AppColor.black.color
        
        toDetailImageButton.setImage(UIImage(named: "arrow"), for: .normal)
        toDetailImageButton.imageView?.contentMode = .scaleAspectFit
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = AppColor.white.color
        collectionView.register(SideMenuPhotoCell.self, forCellWithReuseIdentifier: SideMenuPhotoCell.identifier)
        
        bottomLine.backgroundColor = AppColor.textField.color
    }
    
    private func setUI() {
        addSubview(photoImageView)
        addSubview(photoTitle)
        addSubview(toDetailImageButton)
        addSubview(collectionView)
        addSubview(bottomLine)
    }
    
    private func setConstraint() {
        photoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        photoTitle.snp.makeConstraints { make in
            make.centerY.equalTo(photoImageView.snp.centerY)
            make.leading.equalTo(photoImageView.snp.trailing).offset(4)
        }
        
        toDetailImageButton.snp.makeConstraints { make in
            make.centerY.equalTo(photoImageView.snp.centerY)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func getPhotosObservable() -> Observable<Void> {
        return self.rx.tapGesture().map{ _ in }.asObservable()
    }
}

extension SideMenuPhotoView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let files = files, !files.isEmpty {
            if files.count > 4 {
                return 4
            } else {
                return files.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuPhotoCell.identifier, for: indexPath) as? SideMenuPhotoCell,
              let files = files, !files.isEmpty
        else {
            return UICollectionViewCell()
        }
        
        cell.setDataSource(file: files[indexPath.item])
        
        return cell
    }
}

extension SideMenuPhotoView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.frame.width - 5 * 3) / 4
        return CGSize(width: length, height: length)
    }
}
