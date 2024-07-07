//
//  MultiProfileImageView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/17.
//

import UIKit

final class MultiProfileImageView: UIView {
    
    private var imageViews: [UIImageView] = []
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(participants: [Participant]) {
        self.imageViews = [] // 재사용 이슈
        
        let urls: [String] = participants.map { $0.profilePicture }
        
        for url in urls {
            let imageView = UIImageView()
            imageView.loadImageFromUrl(url:URL(string: url))
            imageView.contentMode = .scaleAspectFill
            self.imageViews.append(imageView)
        }
    }
    
    func setInitialize() {
        setConfig()
        setUI()
        setConstraint()
    }
    
    func resetImageView() {
        self.imageViews.forEach { imageView in
            imageView.snp.removeConstraints()
            imageView.removeFromSuperview()
        }
        self.subviews.first?.removeFromSuperview() // 블러뷰(백드롭 이미지뷰 제거)
        self.imageViews = []
    }
    
    private func setConfig() {
        if imageViews.count > 1 {
            for index in 0 ..< imageViews.count {
                imageViews[index].clipsToBounds = true
                imageViews[index].layer.cornerRadius = 5
            }
        } else {
            imageViews.first?.clipsToBounds = true
            imageViews.first?.layer.cornerRadius = 20
        }
    }
    
    private func setUI() {
        for index in 0 ..< imageViews.count {
            addSubview(imageViews[index])
        }
    }
    
    private func setConstraint() {
        if imageViews.count == 2 {
            imageViews[0].snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[0].snp.height)
                make.centerY.equalToSuperview()
            }
            
            imageViews[1].snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[1].snp.height)
                make.centerY.equalToSuperview()
            }
        } else if imageViews.count == 3 {
            imageViews[0].snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.45)
                make.height.equalTo(imageViews[0].snp.width)
            }
            
            imageViews[1].snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[1].snp.height)
                make.bottom.equalToSuperview()
            }
            
            imageViews[2].snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[2].snp.height)
                make.bottom.equalToSuperview()
            }
        } else if imageViews.count == 4 {
            imageViews[0].snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[0].snp.height)
                make.top.equalToSuperview()
            }
            
            imageViews[1].snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[1].snp.height)
                make.top.equalToSuperview()
            }
            
            imageViews[2].snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[2].snp.height)
                make.bottom.equalToSuperview()
            }
            
            imageViews[3].snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.45)
                make.width.equalTo(imageViews[3].snp.height)
                make.bottom.equalToSuperview()
            }
        } else {
            imageViews[0].snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
