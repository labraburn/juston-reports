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
}
