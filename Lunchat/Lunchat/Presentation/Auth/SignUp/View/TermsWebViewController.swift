//
//  TermsWebViewController.swift
//  Lunchat
//
//  Created by 이경후 on 3/6/24.
//

import UIKit
import WebKit
import RxSwift

final class TermsWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    private let url: URL
    private var webView: WKWebView!
    private let confirmButton = LunchatButton()
    
    init(url: URL) {
        self.url = url
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
    }
    
    private func setConfig() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        confirmButton.setTitle("동의 하기", for: .normal)
        confirmButton.setFont(of: 20)
        confirmButton.setInActive()
    }
    
    private func setUI() {
        view.addSubview(webView)
        view.addSubview(confirmButton)
    }
    
    private func setConstraint() {
        
        let inset = UserDefaults.standard.getSafeAreaInset()
        
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top).offset(-8)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(inset > 20 ? view.safeAreaLayoutGuide.snp.bottomMargin : -12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(62)
        }
    }
    
    func getConfirmObservable() -> Observable<TermType?> {
        let filteredTermType = TermType.allCases.filter { $0.url == url }.first
        return confirmButton.rx.tap
            .withUnretained(self)
            .map { _ in filteredTermType }
            .asObservable()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            confirmButton.isEnabled = true
            confirmButton.setActive()
        } else if scrollView.contentOffset.y < scrollView.contentSize.height {
            confirmButton.isEnabled = false
            confirmButton.setInActive()
        }
    }
}
