//
//  FulrsURL.swift
//  iOS
//
//  Created by Anton Spivak on 30.07.2022.
//

import Foundation
import SwiftyTON

struct FulrsURL {
    
    let originalURL: URL
    let fallbackURL: URL
    
    init?(_ url: URL) {
        guard let host = url.host,
              host.starts(with: "juston.fulrs"),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let urls = Self.decodeURLs(from: components.queryItems)
        else {
            return nil
        }
        
        originalURL = urls.originalURL
        fallbackURL = urls.fallbackURL
    }
    
    private static func decodeURLs(
        from queryItems: [URLQueryItem]?
    ) -> (originalURL: URL, fallbackURL: URL)? {
        guard let originalURL = decodeURL(base64Encoded: queryItems?.filter({ $0.name == "original" }).first?.value),
              let fallbackURL = decodeURL(base64Encoded: queryItems?.filter({ $0.name == "fallback" }).first?.value)
        else {
            return nil
        }
        
        return (originalURL, fallbackURL)
    }
    
    private static func decodeURL(
        base64Encoded string: String?
    ) -> URL? {
        guard let string = string
        else {
            return nil
        }
        
        guard let base64 = Data(base64Encoded: string.base64URLUnescaped()),
              let decoded = String(data: base64, encoding: .utf8)
        else {
            return nil
        }
        
        return URL(string: decoded)
    }
}
