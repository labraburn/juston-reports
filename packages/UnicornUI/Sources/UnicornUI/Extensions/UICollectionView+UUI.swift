//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

extension UICollectionView {
    open func uui_scrollToItem(
        at indexPath: IndexPath,
        at scrollPosition: UICollectionView.ScrollPosition,
        animated: Bool
    ) throws {
        try sui_scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
}
