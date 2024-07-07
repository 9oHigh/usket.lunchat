//
//  KakaoSignInButton.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/21.
//

import UIKit

final class KakaoSignInButton: UIButton {
    
    private let kakaoImageView = UIImageView(image: UIImage(named: "kakao"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(kakaoImageView)
    }
    
    private func setConstraint() {
        kakaoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
