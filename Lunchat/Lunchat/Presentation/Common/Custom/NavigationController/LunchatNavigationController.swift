//
//  LunchatNavigationController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/04/17.
//

import UIKit

final class LunchatNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
    }
    
    private func setConfig() {
        
        view.backgroundColor = AppColor.white.color
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = AppColor.white.color
        barAppearance.buttonAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.font: AppFont.shared.getBoldFont(size: 24),
            NSAttributedString.Key.foregroundColor: AppColor.black.color]
        barAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: AppFont.shared.getBoldFont(size: 24),
            NSAttributedString.Key.foregroundColor: AppColor.black.color]
        barAppearance.shadowColor = .clear
         
        navigationBar.tintColor = AppColor.black.color
        navigationBar.standardAppearance = barAppearance
        navigationBar.scrollEdgeAppearance = barAppearance
    }
}
