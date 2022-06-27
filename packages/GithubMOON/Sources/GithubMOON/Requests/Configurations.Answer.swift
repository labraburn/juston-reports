//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public extension Configurations {
    
    struct Answer: Response {
        
        public let banners: [FailableDecodable<Banner>]
    }
}
