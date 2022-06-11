//
//  Created by Anton Spivak
//

import Foundation

public struct KeychainAccessGroup: AccessGroup {
    
    #if DEBUG
    public static let shared: KeychainAccessGroup = KeychainAccessGroup("RC58426QBN.group.com.hueton.debug.family")
    #else
    public static let shared: KeychainAccessGroup = KeychainAccessGroup("RC58426QBN.group.com.hueton.family")
    #endif
    
    public let label: String
    
    private init(_ label: String) {
        self.label = label
    }
}
