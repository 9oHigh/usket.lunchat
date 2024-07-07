//
//  UIViewController+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/18.
//

import UIKit

extension UIViewController {
    
    func setBottomLine() {
        let lineView = UIView(frame: CGRect(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 0, width: UIScreen.main.bounds.width, height: 1))
        lineView.backgroundColor = AppColor.black.color.withAlphaComponent(0.15)
        
        view.addSubview(lineView)
    }
    
    func deleteBottomLine() {
        view.subviews.forEach { subview in
            if subview.backgroundColor == AppColor.black.color.withAlphaComponent(0.15) {
                subview.removeFromSuperview()
            }
        }
    }
    
    // FirstViewController
    func setNavBackButton(title: String) {
        let backButton = UIBarButtonItem()
        backButton.title = title
        self.navigationItem.backBarButtonItem = backButton
    }
    
    // SecondViewController
    func unSetNavBackButton(title: String) {
        let leftButton = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        leftButton.image = nil
        leftButton.isEnabled = false
        leftButton.setTitleTextAttributes([.foregroundColor: AppColor.black.color, .font: AppFont.shared.getBoldFont(size: 24)], for: .disabled)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 22

        self.navigationItem.leftBarButtonItems = [space, leftButton]
    }

    func addCoverView(to view: UIView) {
        let coverView = UIView()
        coverView.backgroundColor = AppColor.black.color.withAlphaComponent(0.45)
        view.addSubview(coverView)
        
        coverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setBackground() {
        if let keyWindow = UIApplication.shared.keyWindow {
            addCoverView(to: keyWindow)
        } else {
            addCoverView(to: view)
        }
    }

    func unsetBackground() {
        var viewsToCheck: [UIView] = []

        if let keyWindow = UIApplication.shared.keyWindow {
            viewsToCheck.append(contentsOf: keyWindow.subviews)
        }
        
        viewsToCheck.append(contentsOf: view.subviews)

        viewsToCheck.forEach { sub in
            if sub.backgroundColor == AppColor.black.color.withAlphaComponent(0.45) {
                sub.removeFromSuperview()
            }
        }
    }
}
