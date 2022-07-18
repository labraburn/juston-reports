//
//  TopupViewController.swift
//  iOS
//
//  Created by Anton Spivak on 18.07.2022.
//

import UIKit
import HuetonUI
import WebKit

protocol TopupViewControllerDelegate: AnyObject {
    
    func topupViewController(
        _ viewController: TopupViewControllerDelegate,
        didFinishWithError error: Error?
    )
}

class TopupViewController: SafariViewController {
    
    weak var delegate: TopupViewControllerDelegate? = nil
    
    init() {
        super.init(initial: .html(value: .venera), navigationItems: [.url], bottomItems: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if let iframe = navigationAction.targetFrame,
           !iframe.isMainFrame,
           let url = navigationAction.request.url,
           let host = url.host,
           host.contains("venera.exchange")
        {
            // TODO: Handle completion
        }
        
        return await super.webView(webView, decidePolicyFor: navigationAction)
    }
}

private extension String {
    
    static let venera =
    """
    <!DOCTYPE html>
    <html>
    <head>
    <title>Top-up balance</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0">
    <style>
    body {
      background-color: #10080E;
      width: 100%;
      height: 100%;
      margin: 0px;
    }
    div {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      margin: 0px;
    }
    iframe {
      border-style: none;
      width: 360px;
      height: 540px;
    }
    </style>
    </head>
    <body>
    <div>
    <iframe class="iframe" src="https://iframe.venera.exchange/?theme=dark" frameborder="0"></iframe>
    </div>
    </body>
    </html>
    """
}
