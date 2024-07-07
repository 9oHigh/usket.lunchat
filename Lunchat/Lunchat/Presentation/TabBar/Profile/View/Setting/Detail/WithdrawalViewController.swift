//
//  WithdrawalViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/14.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalViewController: BaseViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let withdrawalLabel = UILabel()
    private let withdrawalButton = LunchatButton()
    private let otherReasonView = WithdrawalOtherReasonView()
    private var reason: String = WithdrawalType.deleteRecord.rawValue
        
    private let viewModel: SettingViewModel
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBottomLine()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
    }

    private func setConfig() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        tableView.backgroundColor = AppColor.white.color
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WithdrawalTableViewCell.self, forCellReuseIdentifier: WithdrawalTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        otherReasonView.isHidden = true
        
        withdrawalLabel.font = AppFont.shared.getRegularFont(size: 14)
        withdrawalLabel.textColor = AppColor.purple.color
        withdrawalLabel.text = "회원탈퇴를 하시면 보유중인 쪽지는 환불되지 않습니다."
        withdrawalLabel.textAlignment = .center
        
        withdrawalButton.setFont(of: 16)
        withdrawalButton.setTitle("회원탈퇴", for: .normal)
    }
    
    @objc
    private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func setUI() {
        view.addSubview(tableView)
        view.addSubview(otherReasonView)
        view.addSubview(withdrawalLabel)
        view.addSubview(withdrawalButton)
    }
    
    private func setConstraint() {
        
        let bottomInset = UserDefaults.standard.getSafeAreaInset()

        tableView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(withdrawalLabel.snp.top).offset(-8)
        }

        withdrawalLabel.snp.remakeConstraints { make in
            make.leading.equalTo(8)
            make.trailing.equalTo(8)
            make.bottom.equalTo(withdrawalButton.snp.top).offset(-20)
        }
        
        withdrawalButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.92)
            make.height.equalToSuperview().multipliedBy(0.06)
            make.bottom.equalTo(bottomInset > 20 ? -bottomInset : -8)
        }
    }
    
    private func bind() {

        let input = SettingViewModel.Input(sendFeedbackSignal: nil)
        _ = viewModel.transform(input: input)
        
        withdrawalButton.rx.tap.subscribe({ [weak self] _ in
            guard let self = self else { return }
            let viewController = self.getUserWithdrawal()
            self.present(viewController, animated: false)
        })
        .disposed(by: disposeBag)
    }
    
    private func getUserWithdrawal() -> UserWithdrawal {
        let viewController = UserWithdrawal()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCancelButtonObservable().subscribe({ [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            guard let self = self else { return }
            if self.otherReasonView.isHidden {
                self.viewModel.withdrawal(reason: self.reason)
            } else {
                self.viewModel.withdrawal(reason: self.otherReasonView.getReasonText())
            }
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        return viewController
    }
}

extension WithdrawalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        let upper = UIView()
        
        upper.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { $0.leading.equalTo(20) }
        
        headerLabel.textColor = AppColor.purple.color
        headerLabel.font = AppFont.shared.getBoldFont(size: 14)
        headerLabel.text = "탈퇴 사유를 선택해 주세요"
        
        return upper
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 235
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return otherReasonView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WithdrawalType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WithdrawalTableViewCell.identifier, for: indexPath) as? WithdrawalTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setDataSource(WithdrawalType.allCases[indexPath.row].rawValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? WithdrawalTableViewCell
        cell?.setClicked()
        
        if WithdrawalType.allCases[indexPath.row] == .otherReason {
            self.otherReasonView.isHidden = false
        } else {
            self.otherReasonView.isHidden = true
            self.reason = WithdrawalType.allCases[indexPath.row].rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? WithdrawalTableViewCell
        cell?.setNotClicked()
    }
}

