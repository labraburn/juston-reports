//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public struct DefaultMOON: HuetonMOON {
    
    public var endpoint: URL {
        guard let url = URL(string: "http://test.hueton3000.com")
        else {
            fatalError("Can't happend.")
        }
        return url
    }
    
    public init() {}
}
