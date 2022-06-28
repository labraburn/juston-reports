//
//  URL.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import Foundation

extension URL {
    
    enum FaviconURLSize: Int {
        
        case s = 16
        case m = 32
        case l = 64
        case xl = 128
        case xxl = 256
        case xxxl = 512
    }
    
    func genericFaviconURL(
        with size: FaviconURLSize = .xl
    ) -> URL? {
        let host = self.host ?? self.absoluteString
        return URL(
            string: "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain_url=\(host)"
        )
    }
}
