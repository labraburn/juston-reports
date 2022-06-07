//
//  Created by Anton Spivak
//

import Foundation

public protocol Request {
    
    associatedtype R: Response
    
    var endpoint: String { get }
    
    var parameters: Encodable { get }
    var headers: [String : String] { get }
    
    var kind: Kind { get }
}

public extension Request {
    
    var parameters: Encodable {
        [String : String]()
    }
    
    var headers: [String : String] {
        [
            "Content-Type" : "application/json"
        ]
    }
}
