//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

open class DiffableCollectionView: SUICollectionView {
    open var isContentOffsetUpdatesLocked: Bool {
        get { super.sui_isContentOffsetUpdatesLocked }
        set { super.sui_isContentOffsetUpdatesLocked = newValue }
    }

    open func removeContentOffsetRestorationAnchor() {
        sui_removeContentOffsetRestorationAnchor()
    }
}
