//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public extension Configurations {
    
    struct Banner: Decodable {
        
        public let title: String
        public let subtitle: String?
        public let imageURL: URL
        public let action: Action
    }
}
