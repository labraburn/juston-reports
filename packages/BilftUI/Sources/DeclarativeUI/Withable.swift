//
//  Created by Anton Spivak
//

import Foundation

public protocol ObjectWithable: AnyObject {
    // swiftlint:disable:next type_name
    associatedtype T

    /// Provides a closure to configure instances inline.
    /// - Parameter closure: A closure `self` as the argument.
    /// - Returns: Simply returns the instance after called the `closure`.
    @discardableResult
    func with(_ closure: (_ instance: T) -> Void) -> T
}

public extension ObjectWithable {
    @discardableResult
    func with(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: ObjectWithable {}
