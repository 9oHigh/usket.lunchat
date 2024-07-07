//
//  GoogleSignInButton.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/21.
//

/*
import UIKit
import GoogleSignIn

final class GIDSignInButton: UIButton {

    private let googleImageView = UIImageView(image: UIImage(named: "google"))
    private let googleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraint()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    private func setConfig() {
        googleLabel.font = .boldSystemFont(ofSize: 15)
        googleLabel.textColor = AppColor.white.color
        googleLabel.text = "구글 로그인"
        backgroundColor = UIColor.init(hex: "#4285F4")
        
        clipsToBounds = true
        layer.cornerRadius = 5
    }
    
    private func setUI() {
        addSubview(googleImageView)
        addSubview(googleLabel)
    }
    
    private func setConstraint() {
        googleImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-2)
            make.top.equalToSuperview().offset(-2)
            make.bottom.equalToSuperview().offset(2)
            make.height.equalTo(googleImageView.snp.width)
        }
        
        googleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
*/
