//
//  Created by Anton Spivak
//

import Foundation

public struct KeychainAccessGroup: AccessGroup {
    
    #if DEBUG
    public static let shared: KeychainAccessGroup = KeychainAccessGroup("76AEM4P5DW.group.com.hueton.debug")
    #else
    public static let shared: KeychainAccessGroup = KeychainAccessGroup("76AEM4P5DW.group.com.hueton")
    #endif
    
    public let label: String
    
    private init(_ label: String) {
        self.label = label
    }
}
