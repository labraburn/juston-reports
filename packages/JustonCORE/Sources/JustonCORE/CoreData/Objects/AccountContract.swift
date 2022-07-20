//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

public struct AccountContract {
    
    public let address: Address
    public let kind: Contract.Kind?
    
    public init(
        address: Address,
        kind: Contract.Kind?
    ) {
        self.address = address
        self.kind = kind
    }
}
