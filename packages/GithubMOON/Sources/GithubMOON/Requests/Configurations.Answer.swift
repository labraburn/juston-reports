//
//  Created by Anton Spivak
//

import Foundation
import JustonMOON

public extension Configurations {
    
    struct Answer: Response {
        
        public let banners: [FailableDecodable<Banner>]
    }
}
