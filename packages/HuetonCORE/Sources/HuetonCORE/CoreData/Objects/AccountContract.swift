//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

public struct AccountContract {
    
    public let address: Address.RawAddress
    public let kind: Contract.Kind?
    
    public init(
        address: Address.RawAddress,
        kind: Contract.Kind?
    ) {
        self.address = address
        self.kind = kind
    }
}
