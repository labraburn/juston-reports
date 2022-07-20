//
//  TopupViewController.swift
//  iOS
//
//  Created by Anton Spivak on 18.07.2022.
//

import UIKit
import JustonUI
import WebKit

protocol TopupProviderViewControllerDelegate: AnyObject {
    
    func topupProviderViewController(
        _ viewController: TopupProviderViewController,
        didFinishWithError error: Error?
    )
}

class TopupProviderViewController: SafariViewController {
    
    weak var delegate: TopupProviderViewControllerDelegate? = nil
    
    init(address: String) {
        super.init(
            initial: .html(value: .venera(address: address)),
            navigationItems: [.url], bottomItems: []
        )
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
            // here we go inside iframe
        }
        
        // This redirect comes from payment gateway inside main frame
        if let iframe = navigationAction.targetFrame,
           iframe.isMainFrame,
           navigationAction.request.url?.absoluteString == "https://venera.exchange/"
        {
            delegate?.topupProviderViewController(
                self,
                didFinishWithError: nil
            )
        }
        
        return await super.webView(webView, decidePolicyFor: navigationAction)
    }
}

extension TopupProviderViewController: PreferredContentSizeHeightViewController {
    
    func preferredContentSizeHeight(
        with containerFrame: CGRect
    ) -> CGFloat {
        return 36 + 540 + view.safeAreaInsets.bottom // 36 - topNavigationView/ 540 - iframe height
    }
}

private extension String {
    
    static func venera(address: String) -> String {
    """
    <!DOCTYPE html>
    <html>
    <head>
    <title>VENERA</title>
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
    <iframe class="iframe" src="https://iframe.venera.exchange/?dark&theme=juston&address=\(address)&disableAddr=true" frameborder="0"></iframe>
    </div>
    </body>
    </html>
    """
    }
}
