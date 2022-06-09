//
//  Created by Anton Spivak
//

import UIKit
import WebKit

final class SafariWebView: WKWebView {
    
    var additionalSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            safeAreaInsetsDidChange()
        }
    }

    override var safeAreaInsets: UIEdgeInsets {
        additionalSafeAreaInsets
    }
}
