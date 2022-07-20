//
//  Safari3WebView.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import WebKit

class Safari3WebView: WKWebView {
    
    var customSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = customSafeAreaInsets
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(
                top: customSafeAreaInsets.top,
                bottom: customSafeAreaInsets.bottom
            )
            
            safeAreaInsetsDidChange()
        }
    }
    
    override init(
        frame: CGRect,
        configuration: WKWebViewConfiguration
    ) {
        super.init(
            frame: frame,
            configuration: configuration
        )
        
        // To avoid flash on start
        
        backgroundColor = .jus_backgroundPrimary
        isOpaque = false
        
        loadHTMLString(
            "<html style=\"background-color:#10080E\"></html>",
            baseURL: nil
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.isOpaque = true
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc(_computedContentInset) // css.env(safe-area-insets)
    func _computedContentInset() -> UIEdgeInsets {
        customSafeAreaInsets
    }
    
    @objc(_computedObscuredInset) // css.env(safe-area-insets)
    func _computedObscuredInset() -> UIEdgeInsets {
        customSafeAreaInsets
    }

    @objc(_scrollViewSystemContentInset) // css.env(safe-area-insets)
    func _scrollViewSystemContentInset() -> UIEdgeInsets {
        customSafeAreaInsets
    }
    
    func updateUserAgetForURL(_ url: URL?) {
        guard let host = url?.host
        else {
            customUserAgent = nil
            return
        }
        
        var juston = false
        let hosts = [
            "scaleton",
            "biton",
            "getgems",
            "disintar",
            "tonmarket",
            "ton" // haha
        ]
        
        for value in hosts {
            juston = host.contains(value)
            if juston {
                break
            }
        }
        
        customUserAgent = juston ? "JUSTON" : nil
    }
}
