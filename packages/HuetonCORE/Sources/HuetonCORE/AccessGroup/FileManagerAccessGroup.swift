//
//  Created by Anton Spivak
//

import Foundation

public struct FileManagerAccessGroup: AccessGroup {
    
    #if DEBUG
    public static let shared: FileManagerAccessGroup = FileManagerAccessGroup("group.com.hueton.debug")
    #else
    public static let shared: FileManagerAccessGroup = FileManagerAccessGroup("group.com.hueton")
    #endif
    
    public let label: String
    
    private init(_ label: String) {
        self.label = label
    }
}
