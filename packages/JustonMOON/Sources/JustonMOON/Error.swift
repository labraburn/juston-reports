//
//  Created by Anton Spivak
//

import Foundation

public enum Error {
    
    case url(URLError)
    case http(HTTPURLResponse?)
    case decoding(Swift.Error)
    
    case wrongContentType
    case unsupportedContentType
}

extension Error: Swift.Error {}
