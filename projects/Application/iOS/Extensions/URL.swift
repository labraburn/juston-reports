//
//  URL.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import Foundation

extension URL {
    
    var genericFaviconURL: URL? {
        guard let host = host
        else {
            return nil
        }
        
        return URL(string: "https://www.google.com/s2/favicons?sz=96&domain_url=\(host)")
    }
}
