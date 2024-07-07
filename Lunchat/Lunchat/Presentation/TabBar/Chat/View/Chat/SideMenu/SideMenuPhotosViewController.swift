//
//  SideMenuPhotosViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/08/10.
//

import UIKit

final class SideMenuPhotosViewController: BaseViewController, DetailPhotoDelegate {

    private let tableView = UITableView()
    private let filesWithDate: [String: [FileInfo]]
    private let sortedDates: [String]
    private weak var chatViewDelegate: ChatViewDelegate?
    
    init(filesWithDate: [String: [FileInfo]], delegate: ChatViewDelegate) {
        self.sortedDates = filesWithDate.keys.sorted(by: >)
        self.filesWithDate = filesWithDate
        self.chatViewDelegate = delegate
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
        tableView.reloadData()
    }

    private func setConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SideMenuPhotosTableViewCell.self, forCellReuseIdentifier: SideMenuPhotosTableViewCell.identifier)
    }
    
    private func setUI() {
        view.addSubview(tableView)
    }
    
    private func setConstraint() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SideMenuPhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filesWithDate.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuPhotosTableViewCell.identifier, for: indexPath) as? SideMenuPhotosTableViewCell {
            let sectionKey = sortedDates[indexPath.section]
            cell.setDataSource(files: filesWithDate[sectionKey] ?? [])
            cell.detailPhotoDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let titleLabel = UILabel()
        titleLabel.font = AppFont.shared.getBoldFont(size: 12)
        titleLabel.textColor = UIColor.black
        
        let sectionKey = sortedDates[section]
        titleLabel.text = sectionKey.toPhotoTime
        
        headerView.addSubview(titleLabel)
        headerView.backgroundColor = AppColor.white.color
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(-12)
            make.leading.equalTo(12)
        }
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionKey = sortedDates[indexPath.section]
        let files = filesWithDate[sectionKey]
        
        if let filesCount = files?.count {
            if filesCount <= 3 {
                return 132
            } else {
                return CGFloat((filesCount / 3 + 1) * 132)
            }
        }
        
        return 132
    }
    
    func showDetailPhoto(photoUrl: String, date: String) {
        chatViewDelegate?.showPhotoDetail(photoUrl: photoUrl, date: date)
    }
}
