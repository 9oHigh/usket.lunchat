//
//  BaseBottomSheet.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/03.
//

import UIKit
import RxGesture
import RxSwift

class DefaultBaseBottomSheet: UIViewController {

    let contentView = UIView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    private var hideCompletion: (() -> Void)? = nil
    
    lazy var centerCheckButton = LunchatButton()
    lazy var cancelButton = LunchatButton()
    lazy var checkButton = LunchatButton()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    func setImage(_ type: DefaultBottomSheetTopItemType) {
        imageView.image = UIImage(named: type.rawValue)
    }
    
    func setButtons(_ type: DefaultBottomSheetButtonType) {
        switch type {
        case .center:
            contentView.addSubview(centerCheckButton)
        case .divided:
            contentView.addSubview(cancelButton)
            contentView.addSubview(checkButton)
        }
    }
    
    private func setConfig() {
        contentView.backgroundColor = .white
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = 5
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = AppFont.shared.getBoldFont(size: 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColor.purple.color
        titleLabel.numberOfLines = 1
        
        detailLabel.font = AppFont.shared.getRegularFont(size: 16)
        detailLabel.textAlignment = .center
        detailLabel.textColor = AppColor.grayText.color
        detailLabel.numberOfLines = 3
        
        centerCheckButton.setFont(of: 18)
        centerCheckButton.setTitle("확인", for: .normal)
        
        cancelButton.setFont(of: 16)
        cancelButton.setTitle("취소", for: .normal)
        checkButton.setFont(of: 16)
        checkButton.setTitle("확인", for: .normal)
        view.backgroundColor = AppColor.black.color.withAlphaComponent(0.45)
    }
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            contentView.frame.origin.y = keyWindow.bounds.size.height
        }
    }
    
    private func bind() {
        view.rx.tapGesture(configuration: { gestureRecognizer, delegate in
            delegate.simultaneousRecognitionPolicy = .never
            gestureRecognizer.cancelsTouchesInView = false
        })
        .when(.recognized)
        .subscribe(onNext: { [weak self] gesture in
            guard let self = self else { return }
            
            let location = gesture.location(in: self.view)
            if !self.isTouchInContentViewOrSubViews(location: location) {
                self.hide()
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func isTouchInContentViewOrSubViews(location: CGPoint) -> Bool {
        if contentView.frame.contains(location) {
            return true
        }
        
        for subview in contentView.subviews {
            if subview.frame.contains(location) {
                return true
            }
        }
        
        return false
    }
    
    func setHidable(completion: @escaping () -> Void) {
        self.hideCompletion = completion
    }
    
    private func hide() {
        (self.hideCompletion ?? { })()
    }
}
