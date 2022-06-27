//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public struct Configurations {}

/// GET
public extension Configurations {
    
    struct GET: Request {
        
        public typealias R = Answer
        
        public let endpoint: String = "index.json"
        public let kind: Kind = .GET
        public let parameters: Encodable
        
        public init() {
            self.parameters = Data()
        }
    }
}
