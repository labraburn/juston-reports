//
//  Created by Anton Spivak
//

import Foundation

public extension NSMutableAttributedString {
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
        @AttributedStringBuilder _ builder: () -> [NSAttributedString]
    ) {
        self.init()
        builder().forEach { append($0) }
    }
}
