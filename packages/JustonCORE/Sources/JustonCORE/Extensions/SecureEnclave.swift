//
//  Created by Anton Spivak
//

import Foundation
import CryptoKit

extension SecureEnclave {
    
    static var isDeviceAvailable: Bool {
        TARGET_OS_SIMULATOR == 0 && SecureEnclave.isAvailable
    }
}
