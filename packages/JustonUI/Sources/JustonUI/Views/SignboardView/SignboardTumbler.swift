//
//  Created by Anton Spivak.
//

import UIKit

public enum SignboardTumbler {
    
    case on
    case off
}

public extension Array where Element == SignboardTumbler {
    
    static func on(count: Int) -> Array<Element> {
        Array(repeating: .on, count: count)
    }
    
    static func off(count: Int) -> Array<Element> {
        Array(repeating: .off, count: count)
    }
}
