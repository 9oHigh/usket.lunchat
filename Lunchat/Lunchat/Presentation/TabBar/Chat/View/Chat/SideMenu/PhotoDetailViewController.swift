//
//  PhotoDetailViewController.swift
//  Lunchat
//
//  Created by 이경후 on 11/26/23.
//

import UIKit

final class PhotoDetailViewController: BaseViewController {
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
    init(photoUrl: String, date: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.loadImageFromUrl(url: URL(string: photoUrl), isDownSampling: false)
        titleLabel.text = date.toPhotoTime
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.image = nil
    }
    
    private func setConfig() {
        titleLabel.font = AppFont.shared.getBoldFont(size: 12)
        titleLabel.textColor = AppColor.black.color
        
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setUI() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(16)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
