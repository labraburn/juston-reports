//
//  ServiceURL.swift
//  iOS
//
//  Created by Anton Spivak on 16.06.2022.
//

import Foundation

extension URL {
    
    static let hueton = URL(string: "https://hueton.com")!
    
    static let privacyPolicy = URL(string: "https://hueton.com/privacy")!
    static let termsOfUse = URL(string: "https://hueton.com/terms")!
    
    static let appStore = URL(string: "itms-apps://apple.com/app/id1629214799")!
    
    static let telegramChat = URL(string: "https://t.me/hueton_ru_chat")!
    static let telegramChannel = URL(string: "https://t.me/hueton_ru")!
    
    static let twitter = URL(string: "https://twitter.com/thehueton")!
    
    static func searchURL(withQuery text: String) -> URL? {
        guard var components = URLComponents(string: "https://www.google.com/search")
        else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: text)
        ]
        
        return components.url
    }
}
