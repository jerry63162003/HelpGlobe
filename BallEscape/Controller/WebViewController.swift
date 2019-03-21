//
//  WebViewController.swift
//  BallEscape
//
//  Created by Liqiu Li on 2019/3/21.
//  Copyright © 2019年 xxx. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController {
    
    var urlStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        // 设置偏好设置
        config.preferences = WKPreferences()
        // 默认为0
        config.preferences.minimumFontSize = 10
        // 默认认为YES
        config.preferences.javaScriptEnabled = true
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        // 通过JS与webview内容交互
        config.userContentController = WKUserContentController()
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        return webView
    }()
    
    func commonInit() {
        let url = URL.init(string: urlStr)
        guard url != nil else {
            return
        }
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(webView)
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        webView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
    }
}
