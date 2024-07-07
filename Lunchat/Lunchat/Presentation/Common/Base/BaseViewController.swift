//
//  BaseViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/04.
//

import UIKit

class BaseViewController: UIViewController {
    
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var isShowingKeyboard: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        addObservers()
    }
    
    private func setConfig() {
        view.backgroundColor = .white
        
        loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = .clear
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = AppColor.purple.color
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
    }
    
    private func setUI() {
        loadingView.addSubview(activityIndicator)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showLoadingView(_ isPurchasing: Bool = false) {
        view.addSubview(loadingView)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        
        // 일련의 오류로 화면을 클릭하지 못하는 것을 방지하기 위함
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if !isPurchasing {
                self?.hideLoadingView()
            }
        }
    }
    
    func hideLoadingView(_ interval: CGFloat = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.loadingView.removeFromSuperview()
            UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        }
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard !isShowingKeyboard,
              let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeField = findActiveTextFieldOrTextView(in: view),
              let activeFrame = activeField.superview?.convert(activeField.frame, to: view)
        else { return }
        
        let keyboardHeight = keyboardFrame.size.height
        let maxY = activeFrame.maxY
        let keyboardTop = view.frame.size.height - keyboardHeight
        
        if maxY > keyboardTop {
            let yOffset = maxY - keyboardTop
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y -= yOffset
            }
        }
        
        isShowingKeyboard = true
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        view.frame.origin.y = 0
        isShowingKeyboard = false
    }
    
    func findActiveTextFieldOrTextView(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder && (subview is UITextField || subview is UITextView) {
                return subview
            }
            if let foundSubview = findActiveTextFieldOrTextView(in: subview) {
                return foundSubview
            }
        }
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
