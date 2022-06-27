//
//  WKWeb3EventDispatcher.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation
import WebKit

protocol WKWeb3EventDispatcher: AnyObject {
    
    func dispatch(
        _ response: String
    ) async throws
}

extension WKWebView: WKWeb3EventDispatcher {
    
    func dispatch(
        _ response: String
    ) async throws {
        try await evaluateJavaScript(
            "window.dispatchEvent(new CustomEvent(\"HUETON3ER\", { \"detail\": \(response) }));"
        )
    }
}
