//
//  FeedbackViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/02.
//

import UIKit
import RxSwift

final class FeedbackViewController: BaseViewController {
    
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let textView = LunchatTextView()
    private let checkButton = LunchatButton()
    
    private var viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
        bind()
        setBottomLine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.resetViewModel()
        deleteBottomLine()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setConfig() {
        titleLabel.text = "런챗의 발전을 위해 의견을 남겨주세요!"
        titleLabel.textColor = AppColor.purple.color
        titleLabel.font = AppFont.shared.getBoldFont(size: 14)
        
        subLabel.text = "자세하게 적어주시면 서비스 개선에 큰 도움이 됩니다."
        subLabel.textColor = AppColor.grayText.color
        subLabel.font = AppFont.shared.getRegularFont(size: 12)
        
        textView.setPlaceholer("보다 자세하게 적어주시면 감사하겠습니다 :)")
        
        checkButton.setTitle("확인", for: .normal)
        checkButton.setFont(of: 16)
        checkButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(titleLabel)
        view.addSubview(subLabel)
        view.addSubview(textView)
        view.addSubview(checkButton)
    }
    
    private func setConstraint() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.leading.equalTo(16)
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(16)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.92)
            make.height.equalToSuperview().multipliedBy(0.36)
            make.centerX.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    private func bind() {
        
        let input = SettingViewModel.Input(sendFeedbackSignal: self.checkButton.rx.tap.map { Feedback(content: self.textView.text) }.asSignal(onErrorJustReturn: Feedback(content: "")))
        _ = viewModel.transform(input: input)

        textView.getTextObservable().subscribe({ [weak self] text in
            if let text = text.element {
                if text.isEmpty || text == self?.textView.getPlaceholder() {
                    self?.checkButton.isEnabled = false
                    self?.checkButton.setInActive()
                } else {
                    self?.checkButton.isEnabled = true
                    self?.checkButton.setActive()
                }
            } else {
                self?.checkButton.isEnabled = false
                self?.checkButton.setInActive()
            }
        })
        .disposed(by: disposeBag)
    }
}
