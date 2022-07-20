//
//  Created by Anton Spivak
//

import UIKit

public extension UIView {
    /// Simple extensions for UIView that can easily build hierarchy
    ///
    /// ```
    /// UIView {
    ///     UILabel()
    ///     if anyFlag {
    ///         UILabel()
    ///     }
    /// }
    /// ```
    convenience init(
        @SubviewsBuilder _ builder: () -> [UIView]
    ) {
        self.init()
        builder().forEach { addSubview($0) }
    }
}
