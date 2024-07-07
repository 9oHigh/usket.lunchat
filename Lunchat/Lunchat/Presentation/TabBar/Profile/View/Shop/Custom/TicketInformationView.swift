//
//  TicketInformationView.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/16.
//

import UIKit
import RxSwift
import RxCocoa

class TicketInformationView: UIView {
    
    static let identifier = "TicketInformationView"
    
    private let titleLabel = UILabel()
    private let bottomLine = UIView()
    
    private let detailView = UIView()
    private let detailTextView = UITextView()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        
        backgroundColor = AppColor.thinGrayBackground.color
        detailView.backgroundColor = AppColor.thinGrayBackground.color
        bottomLine.backgroundColor = AppColor.textField.color
        
        titleLabel.text = "쪽지 이용 안내"
        titleLabel.textColor = AppColor.deepGrayText.color
        titleLabel.font = AppFont.shared.getBoldFont(size: 15)

        detailTextView.delegate = self
        detailTextView.text =
        """
        ∙회원이 정상적으로 구매한 쪽지는 별도 사용제한의 공지 없는한, 런챗의 모든 플랫폼에서 사용할 수 있습니다.
        ∙아이오에스(ios) 및 안드로이드(android)앱에서 충전한 쪽지의 구매취소는 각각의 앱스토어 (app store 및 play store)의 정책 상 해당 앱스토어의 고객센터를 통해서만 가능합니다.
        ∙앱스토어 고객센터는 여기를 클릭하십시오.
        ∙쪽지의 구매내역은 내 프로필 > 쪽지샵 > 구매내역에서 확인할 수 있습니다.
        ∙쪽지의 충전 금액은 상품 페이지에 표시되는 금액 기준이며, 해외결제의 경우 환율 등에 의하여 표시되는 금액과 실제 결제금액 사이에 차이가 있을 수 있습니다. 환율 차이에 따른 차액에 대해서는 런챗이 책임지지 않습니다.
        ∙쪽지의 가격은 부가가치세가 포함되지 않은 가격입니다.
        ∙쪽지의 구매 또는 사용 전 런챗의 관련 서비스이용약관에 대한 동의가 필요합니다.
        ∙런챗 서비스 서비스이용약관에서 정한 회원가입 조건 및 사용 제한 규정 등에 따라 쪽지의 구매 또는 사용이 거부, 제한 또는 일시 사용 정지가 될 수 있음을 양지하시기 바랍니다.
        """
        let attributedString = NSMutableAttributedString(string: detailTextView.text)
        let range = (detailTextView.text as NSString).range(of: "여기를 클릭하십시오.")
        attributedString.addAttribute(.link, value: "https://support.apple.com/ko-kr/apps", range: range)
        attributedString.addAttribute(.foregroundColor, value: AppColor.purple.color, range: range)
        detailTextView.attributedText = attributedString
        detailTextView.linkTextAttributes = [.foregroundColor: AppColor.purple.color]
        
        detailTextView.textColor = AppColor.thinGrayText.color
        detailTextView.backgroundColor = AppColor.thinGrayBackground.color
        detailTextView.isEditable = false
        detailTextView.isSelectable = true
    }
    
    private func setUI() {
        addSubview(titleLabel)
        addSubview(bottomLine)
        addSubview(detailView)
        
        detailView.addSubview(detailTextView)
    }
    
    private func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.leading.equalTo(16)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        detailView.snp.makeConstraints { make in
            make.top.equalTo(bottomLine.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        detailTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(8)
            make.trailing.equalTo(-8)
            make.bottom.equalToSuperview()
        }
    }
}

extension TicketInformationView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
