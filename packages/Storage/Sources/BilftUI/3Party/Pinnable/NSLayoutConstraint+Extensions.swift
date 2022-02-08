//
//  NSLayoutConstraint+Extensions.swift
//
//
//  Created by Kyle Bashour on 1/12/21.
//

import UIKit

public extension NSLayoutConstraint {
    /// Recursively activates array of arrays of constraints
    class func activate(_ constraints: [Any]) {
        let flatten: [NSLayoutConstraint] = constraints.flatten()
        NSLayoutConstraint.activate(flatten)
    }
}

public extension NSLayoutConstraint {
    /// Set the priority on the constraint.
    ///
    /// - Parameter priority: The value of the priority.
    /// - Returns: self
    @discardableResult
    func prioritize(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

private extension Array {
    func flatten<T>(_ index: Int = 0) -> [T] {
        guard index < count else {
            return []
        }

        var flatten: [T] = []

        if let itemArr = self[index] as? [T] {
            flatten += itemArr.flatten()
        }
        else if let element = self[index] as? T {
            flatten.append(element)
        }
        return flatten + self.flatten(index + 1)
    }
}
