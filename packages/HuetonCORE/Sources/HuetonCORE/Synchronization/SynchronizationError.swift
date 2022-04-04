//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

enum SynchronizationError {
    
    case accountDoesNotExists(rawAddress: Address.RawAddress)
}

extension SynchronizationError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case let .accountDoesNotExists(rawAddress):
            return "Can't locate PersistanceAccount for synchronization with address: \(rawAddress.rawValue)."
        }
    }
}
