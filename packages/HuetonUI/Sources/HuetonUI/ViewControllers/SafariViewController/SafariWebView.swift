//
//  Created by Anton Spivak
//

import UIKit
import WebKit

final class SafariWebView: WKWebView {
    
    var additionalSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = additionalSafeAreaInsets
            
            safeAreaInsetsDidChange()
        }
    }

    override var safeAreaInsets: UIEdgeInsets {
        additionalSafeAreaInsets
    }
    
    @objc(_computedContentInset) // css.env(safe-area-insets)
    func _computedContentInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }
    
    @objc(_computedObscuredInset) // css.env(safe-area-insets)
    func _computedObscuredInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }

    @objc(_scrollViewSystemContentInset) // css.env(safe-area-insets)
    func _scrollViewSystemContentInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }
    
    override init(
        frame: CGRect,
        configuration: WKWebViewConfiguration
    ) {
        super.init(
            frame: frame,
            configuration: configuration
        )
        
        loadHTMLString(
            "<html style=\"background-color:#10080E\"></html>",
            baseURL: nil
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
