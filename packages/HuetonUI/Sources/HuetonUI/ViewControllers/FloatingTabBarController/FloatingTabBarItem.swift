//
//  Created by Anton Spivak
//

import UIKit

public final class FloatingTabBarItem: UITabBarItem {
    
    public var customView: UIControl?

    public convenience init(customView: UIControl) {
        self.init()
        self.customView = customView
    }
}
