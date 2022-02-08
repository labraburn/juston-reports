//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Andrew Podkovyrin. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public enum Anchor {
    case top, left, bottom, right
}

public protocol HorizontalAnchors: AnyObject {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
}

public protocol VerticalAnchors: AnyObject {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

public typealias Anchors = HorizontalAnchors & VerticalAnchors

extension UIView: Anchors {}
extension UILayoutGuide: Anchors {}

public extension UIView {
    func pin(
        horizontally horizontalAnchors: HorizontalAnchors,
        left: CGFloat = 0,
        right: CGFloat = 0,
        but exceptAnchor: Anchor? = nil
    ) -> [NSLayoutConstraint] {
        dui_assertLog(translatesAutoresizingMaskIntoConstraints == false)
        return [Anchor.left, Anchor.right].filter { $0 != exceptAnchor }.compactMap {
            if $0 == .left {
                return leadingAnchor.constraint(equalTo: horizontalAnchors.leadingAnchor, constant: left)
            }
            else if $0 == .right {
                return horizontalAnchors.trailingAnchor.constraint(equalTo: trailingAnchor, constant: right)
            }
            else {
                return nil
            }
        }
    }

    func pin(
        vertically verticalAnchors: VerticalAnchors,
        top: CGFloat = 0,
        bottom: CGFloat = 0,
        but exceptAnchor: Anchor? = nil
    ) -> [NSLayoutConstraint] {
        dui_assertLog(translatesAutoresizingMaskIntoConstraints == false)
        return [Anchor.top, Anchor.bottom].filter { $0 != exceptAnchor }.compactMap {
            if $0 == .top {
                return topAnchor.constraint(equalTo: verticalAnchors.topAnchor, constant: top)
            }
            else if $0 == .bottom {
                return verticalAnchors.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom)
            }
            else {
                return nil
            }
        }
    }

    func pin(
        edges anchors: Anchors,
        insets: UIEdgeInsets = .zero,
        but exceptAnchor: Anchor? = nil
    ) -> [NSLayoutConstraint] {
        dui_assertLog(translatesAutoresizingMaskIntoConstraints == false)
        return Array(
            [
                pin(horizontally: anchors, left: insets.left, right: insets.right, but: exceptAnchor),
                pin(vertically: anchors, top: insets.top, bottom: insets.bottom, but: exceptAnchor),
            ].joined()
        )
    }

    func pin(size: CGSize) -> [NSLayoutConstraint] {
        dui_assertLog(translatesAutoresizingMaskIntoConstraints == false)
        return [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
        ]
    }

    func pin(size constant: CGFloat) -> [NSLayoutConstraint] {
        pin(size: CGSize(width: constant, height: constant))
    }
}

public extension UIView {
    func pinned(horizontally horizontalAnchors: HorizontalAnchors, left: CGFloat = 0, right: CGFloat = 0) {
        NSLayoutConstraint.activate(pin(horizontally: horizontalAnchors, left: left, right: right))
    }

    func pinned(vertically verticalAnchors: VerticalAnchors, top: CGFloat = 0, bottom: CGFloat = 0) {
        NSLayoutConstraint.activate(pin(vertically: verticalAnchors, top: top, bottom: bottom))
    }

    func pinned(edges anchors: Anchors, insets: UIEdgeInsets = .zero, but exceptAnchor: Anchor? = nil) {
        NSLayoutConstraint.activate(pin(edges: anchors, insets: insets, but: exceptAnchor))
    }
}
