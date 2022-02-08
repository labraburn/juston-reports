//
//  Created by Anton Spivak
//

import UIKit

public extension NSLayoutConstraint {
    /// Activate the constraints from the builder block
    ///
    /// ```
    /// NSLayoutConstraint.activate {
    ///     myConstraint
    ///     if anyFlag {
    ///         anotherConstraint()
    ///     }
    /// }
    /// ```
    @discardableResult
    static func activate(
        @ConstraintsBuilder _ builder: () -> [NSLayoutConstraint]
    ) -> [NSLayoutConstraint] {
        let constraints = builder()
        activate(constraints)
        return constraints
    }
}
