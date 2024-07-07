//
//  HomeCreateAppointmentCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/19.
//

import UIKit
import RxSwift

final class HomeCreateAppointmentCell: UICollectionViewCell {
    
    static let identifier = "HomeCreateAppointmentCell"
    private var type: HomeCreateAppointmentCellType = .empty
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let createButton = UIButton()
    private let createLabel = UILabel()
    
    private var viewModel: HomeCreateAppointmentCellViewModel?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConfig()
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setType(type: HomeCreateAppointmentCellType) {
        self.type = type
        setConfig()
    }
    
    func setCreateButtonAction(viewModel: HomeCreateAppointmentCellViewModel) {
        self.viewModel = viewModel
        
        createButton.rx.tap.subscribe({ [weak self] _ in
            self?.viewModel?.createAppointment()
        })
        .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = AppColor.white.color
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    private func setConfig() {
        contentView.backgroundColor = AppColor.white.color
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath

        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: type.imageName)

        titleLabel.textColor = AppColor.black.color
        titleLabel.font = AppFont.shared.getBoldFont(size: 22)
        titleLabel.text = type.title
        titleLabel.textAlignment = .center

        subLabel.textColor = AppColor.thinGrayText.color
        subLabel.font = AppFont.shared.getRegularFont(size: 13)
        subLabel.text = type.subTitle
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center

        createButton.contentMode = .scaleAspectFit
        createButton.setImage(UIImage(named: "createButton"), for: .normal)

        createLabel.font = AppFont.shared.getBoldFont(size: 15)
        createLabel.textColor = AppColor.purple.color
        createLabel.text = "밥약 생성"
    }
    
    private func setUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subLabel)
        contentView.addSubview(createLabel)
        contentView.addSubview(createButton)
    }
    
    private func setConstraint() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.55)
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        createButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(32)
            make.height.equalTo(89)
            make.width.equalTo(74)
            make.centerX.equalToSuperview()
        }
        
        createLabel.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
