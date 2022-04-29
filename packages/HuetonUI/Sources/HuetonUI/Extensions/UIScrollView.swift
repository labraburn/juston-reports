//
//  Created by Anton Spivak.
//

import UIKit
import SystemUI

extension UIScrollView {
    
    public var isScrolledToTop: Bool {
        contentOffset == CGPoint(x: 0, y: -adjustedContentInset.top)
    }
    
    public func scrollToTopIfPossible() {
        sui_scroll(toTopIfPossible: true)
    }
}
