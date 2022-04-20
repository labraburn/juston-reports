//
//  W3WebView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import WebKit

final class Web3WebView: WKWebView {

    var customSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            safeAreaInsetsDidChange()
        }
    }

    override var safeAreaInsets: UIEdgeInsets {
        customSafeAreaInsets
    }
}
