//
//  OpenSourceViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/24.
//

import UIKit
import SafariServices

final class OpenSourceViewController: BaseViewController {
    
    private let sectionHeaderView = UIView()
    private let headerView = UIView()
    private let headerLabel = UILabel()
    private let subLabel = UILabel()
    private let separatorLineView = UIView()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setConfig() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = AppColor.white.color
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 135
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OpenSourceTableViewCell.self, forCellReuseIdentifier: OpenSourceTableViewCell.identifier)
        
        headerView.backgroundColor = AppColor.purple.color
        headerLabel.textColor = AppColor.white.color
        headerLabel.font = AppFont.shared.getBoldFont(size: 20)
        headerLabel.text = "OSS Notice - LunChat_ios"
        
        subLabel.textColor = AppColor.thinGrayText.color
        subLabel.font = AppFont.shared.getRegularFont(size: 12)
        subLabel.numberOfLines = 0
        subLabel.text = "* This application is Copyright (c) Lunchat.\n* If you have any questions about these notices, please ask customer service center."
        
        separatorLineView.backgroundColor = AppColor.black.color.withAlphaComponent(0.15)
    }
    
    private func setUI() {
        view.addSubview(tableView)
        sectionHeaderView.addSubview(headerView)
        headerView.addSubview(headerLabel)
        sectionHeaderView.addSubview(subLabel)
        sectionHeaderView.addSubview(separatorLineView)
    }
    
    private func setConstraint() {
        
        let topInset = UserDefaults.standard.getSafeAreaInset()
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        separatorLineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview().multipliedBy(0.928)
        }
    }
}
extension OpenSourceViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OpenSourceType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OpenSourceTableViewCell.identifier, for: indexPath) as? OpenSourceTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setOpenSourceInfo(OpenSourceType.allCases[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webView = SFSafariViewController(url: OpenSourceType.allCases[indexPath.row].url!)
        webView.modalPresentationStyle = .overFullScreen
        self.present(webView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
