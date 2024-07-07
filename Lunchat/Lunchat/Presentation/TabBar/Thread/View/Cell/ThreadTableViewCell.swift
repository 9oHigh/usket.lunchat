//
//  ThreadTableViewCell.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/22.
//

import UIKit

final class ThreadTableViewCell: UITableViewCell {
    
    static let identifier = "ThreadTableViewCell"
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let locationLabel = UILabel()
    private let remainTimeLabel = UILabel()
    private lazy var contentImageView = UIImageView()
    
    private let likeButton = UIButton(type: .custom)
    private let disLikeButton = UIButton(type: .custom)
    
    private var post: Post?
    
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
        titleLabel.text = nil
        contentLabel.text = nil
        locationLabel.text = nil
        remainTimeLabel.text = nil
        contentImageView.image = nil
        likeButton.imageView?.image = nil
        disLikeButton.imageView?.image = nil
        post = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        
        contentImageView.layoutIfNeeded()
        contentImageView.layer.cornerRadius = 5
    }
    
    func setDataSource(post: Post) {
        self.post = post

        titleLabel.text = post.title
        contentLabel.text = post.content
        
        if let fileUrl = post.fileURL {
            contentImageView.loadImageFromUrl(url: URL(string: fileUrl))
            withImageConstraint()
        }
        
        locationLabel.text = post.placeArea
        remainTimeLabel.text = post.remainTime
        
        var config = UIButton.Configuration.plain()
        let originalImage = UIImage(named: post.isLiked ? "like_color" : "like")
        let scaledImage = originalImage?.withRenderingMode(.alwaysOriginal).resized(to: CGSize(width: 12, height: 12))
        config.image = scaledImage
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.shared.getRegularFont(size: 10),
            .foregroundColor: AppColor.grayText.color
        ]
        let title = NSAttributedString(string: "\(post.likeCount)", attributes: titleAttributes)
        
        config.attributedTitle = AttributedString(title)
        config.imagePadding = 4
        config.imagePlacement = .leading
        likeButton.configuration = config

        if post.isDisliked {
            self.disLikeButton.setImage(UIImage(named: "dislike_color"), for: .normal)
        } else {
            self.disLikeButton.setImage(UIImage(named: "dislike"), for: .normal)
        }
    }
    
    private func setConfig() {
        
        selectionStyle = .none
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 16)
        
        contentLabel.font = AppFont.shared.getRegularFont(size: 14)
        contentLabel.textColor = AppColor.grayText.color
        contentLabel.numberOfLines = 1
        
        locationLabel.font = AppFont.shared.getRegularFont(size: 10)
        locationLabel.textColor = AppColor.grayText.color
        
        remainTimeLabel.font = AppFont.shared.getRegularFont(size: 10)
        remainTimeLabel.textColor = AppColor.grayText.color
        
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        
        var config = UIButton.Configuration.plain()
        let originalImage = UIImage(named: "like")
        let scaledImage = originalImage?.withRenderingMode(.alwaysOriginal).resized(to: CGSize(width: 12, height: 12))
        config.image = scaledImage
        
        likeButton.configuration = config
        disLikeButton.setImage(UIImage(named: "dislike"), for: .normal)
    }
    
    private func setUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(remainTimeLabel)
        contentView.addSubview(contentImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(disLikeButton)
    }
    
    private func setConstraint() {
        titleLabel.snp.remakeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(titleLabel.font.pointSize + 4)
        }
        
        contentLabel.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(contentLabel.font.pointSize + 4)
        }
        
        locationLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(locationLabel.font.pointSize + 4)
        }
        
        remainTimeLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.leading.equalTo(locationLabel.snp.trailing).offset(6)
        }
        
        likeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalTo(disLikeButton.snp.leading).offset(-12)
            make.width.equalTo(24)
            make.height.equalTo(12)
        }
        
        disLikeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
    }
    
    private func withImageConstraint() {
        titleLabel.snp.remakeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(titleLabel.font.pointSize + 4)
        }
        
        contentLabel.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview()
            make.trailing.equalTo(contentImageView.snp.leading).offset(6)
            make.height.equalTo(contentLabel.font.pointSize + 4)
        }
        
        locationLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(locationLabel.font.pointSize + 4)
        }
        
        remainTimeLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.leading.equalTo(locationLabel.snp.trailing).offset(6)
        }
        
        contentImageView.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        likeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalTo(disLikeButton.snp.leading).offset(-12)
            make.width.equalTo(24)
            make.height.equalTo(12)
        }
        
        disLikeButton.snp.remakeConstraints { make in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.trailing.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
    }
    
    func getId() -> String? {
        return post?.id
    }
}
