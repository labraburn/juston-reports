//
//  WKWeb3EventDispatcher.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation
import WebKit

protocol WKWeb3EventDispatcher: AnyObject {
    
    var presentationContext: UIViewController? { get }
    
    func dispatch(
        name: String,
        detail: String
    ) async throws
}

extension WKWebView: WKWeb3EventDispatcher {
    
    var presentationContext: UIViewController? {
        nil
    }
    
    func dispatch(
        name: String,
        detail: String
    ) async throws {
        try await evaluateJavaScript(
            "window.dispatchEvent(new CustomEvent(\"\(name)\", { \"detail\": \(detail) }));"
        )
    }
}
