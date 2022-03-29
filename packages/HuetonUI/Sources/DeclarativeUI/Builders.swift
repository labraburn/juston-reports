//
//  Created by Anton Spivak
//

import UIKit

///
/// SubviewsBuilder
///

@resultBuilder
public enum SubviewsBuilder {
    public static func buildBlock() -> [UIView] {
        []
    }

    public static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildIf(_ content: UIView?) -> [UIView] {
        guard let content = content else {
            return []
        }

        return [content]
    }

    public static func buildEither(first: UIView) -> [UIView] {
        [first]
    }

    public static func buildEither(second: UIView) -> [UIView] {
        [second]
    }
}

///
/// ConstraintsBuilder
///

public protocol ConstraintsGroup {
    var constraints: [NSLayoutConstraint] { get }
}

extension NSLayoutConstraint: ConstraintsGroup {
    public var constraints: [NSLayoutConstraint] { [self] }
}

extension Array: ConstraintsGroup where Element == NSLayoutConstraint {
    public var constraints: [NSLayoutConstraint] { self }
}

@resultBuilder
public enum ConstraintsBuilder {
    public static func buildBlock() -> [NSLayoutConstraint] {
        []
    }

    public static func buildBlock(_ components: ConstraintsGroup...) -> [NSLayoutConstraint] {
        components.flatMap(\.constraints)
    }

    public static func buildArray(_ components: [ConstraintsGroup]) -> [NSLayoutConstraint] {
        components.flatMap(\.constraints)
    }

    public static func buildIf(_ content: ConstraintsGroup?) -> [NSLayoutConstraint] {
        content?.constraints ?? []
    }

    public static func buildOptional(_ components: [ConstraintsGroup]?) -> [NSLayoutConstraint] {
        components?.flatMap(\.constraints) ?? []
    }

    public static func buildEither(first: ConstraintsGroup) -> [NSLayoutConstraint] {
        first.constraints
    }

    public static func buildEither(second: ConstraintsGroup) -> [NSLayoutConstraint] {
        second.constraints
    }
}
