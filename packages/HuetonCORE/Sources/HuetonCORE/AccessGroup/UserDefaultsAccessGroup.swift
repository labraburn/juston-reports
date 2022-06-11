//
//  Created by Anton Spivak
//

import Foundation

public struct UserDefaultsAccessGroup: AccessGroup {
    
    #if DEBUG
    public static let shared: UserDefaultsAccessGroup = UserDefaultsAccessGroup("group.com.hueton.debug.family")
    #else
    public static let shared: UserDefaultsAccessGroup = UserDefaultsAccessGroup("group.com.hueton.family")
    #endif
    
    public let label: String
    
    private init(_ label: String) {
        self.label = label
    }
}
