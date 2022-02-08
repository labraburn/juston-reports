//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

public enum SheetPresentationControllerDetent {
    public struct Identifier: RawRepresentable {
        public static let medium: Identifier = .init(rawValue: "com.apple.UIKit.medium")
        public static let large: Identifier = .init(rawValue: "com.apple.UIKit.large")
        public static let small: Identifier = .init(rawValue: "io.1inch.small")

        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    case small
    case medium
    case large
    case dynamic(identifier: String, resolutionBlock: (_ view: UIView) -> CGFloat)

    public static func identifier(for detend: SheetPresentationControllerDetent) -> Identifier {
        switch detend {
        case .small:
            return .small
        case .medium:
            return .medium
        case .large:
            return .large
        case let .dynamic(identifier, _):
            return Identifier(rawValue: identifier)
        }
    }
}

public protocol SheetPresentationController: AnyObject {
    func set(detents: [SheetPresentationControllerDetent])
    func set(selectedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?)
    func set(largestUndimmedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?)
    func set(wantsFullScreen: Bool)
    func performAnimatedChanges(_ changes: @escaping () -> Void)

    var presentationController: UIPresentationController { get }
    var interactionDelegate: SUISheetPresentationControllerInteractionDelegate? { get set }
}

//
// Common iOS initialization
//

public func SheetPresentationControllerUniversalInstantiate(
    presentedViewController: UIViewController,
    presenting: UIViewController?
) -> SheetPresentationController {
    if #available(iOS 15, *) {
        return UISheetPresentationController(
            presentedViewController: presentedViewController,
            presenting: presenting
        )
    }
    else if #available(iOS 13, *) {
        return SUI14SheetPresentationController(
            presentedViewController: presentedViewController,
            presenting: presenting
        )
    }
    else {
        fatalError("_UISheetPresentationController doesn't work on iOS version 12 and lower")
    }
}

//
// iOS 14 and lower
//

@available(iOS, deprecated: 14)
extension SUI14SheetPresentationController: SheetPresentationController {
    public func set(detents: [SheetPresentationControllerDetent]) {
        self.detents = detents.map { detent in
            switch detent {
            case .small:
                return .small()
            case .medium:
                return .medium()
            case .large:
                return .large()
            case let .dynamic(identifier, resolutionBlock):
                return SUI14SheetPresentationControllerDetent(
                    identifier: .init(rawValue: identifier),
                    resolutionBlock: { view in
                        resolutionBlock(view)
                    }
                )
            }
        }
    }

    public func set(selectedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?) {
        if let identifier = identifier {
            selectedDetentIdentifier = .init(rawValue: identifier.rawValue)
        }
        else {
            selectedDetentIdentifier = nil
        }
    }

    public func set(largestUndimmedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?) {
        if let identifier = identifier {
            largestUndimmedDetentIdentifier = .init(rawValue: identifier.rawValue)
        }
        else {
            largestUndimmedDetentIdentifier = nil
        }
    }

    public func set(wantsFullScreen: Bool) {
        setWantsFullscreen(wantsFullScreen)
    }

    public func performAnimatedChanges(_ changes: @escaping () -> Void) {
        animateChanges(changes)
    }

    public var presentationController: UIPresentationController {
        self.presentationController()
    }
}

//
// iOS 15 and upper
//

@available(iOS 15, *)
extension UISheetPresentationController: SheetPresentationController {
    public func set(detents: [SheetPresentationControllerDetent]) {
        self.detents = detents.map { detent in
            switch detent {
            case .small:
                return .small()
            case .medium:
                return .medium()
            case .large:
                return .large()
            case let .dynamic(identifier, resolutionBlock):
                return Detent(
                    identifier: .init(rawValue: identifier),
                    resolutionBlock: { view in
                        resolutionBlock(view)
                    }
                )
            }
        }
    }

    public func set(selectedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?) {
        if let identifier = identifier {
            selectedDetentIdentifier = .init(rawValue: identifier.rawValue)
        }
        else {
            selectedDetentIdentifier = nil
        }
    }

    public func set(largestUndimmedDetentIdentifier identifier: SheetPresentationControllerDetent.Identifier?) {
        if let identifier = identifier {
            largestUndimmedDetentIdentifier = .init(rawValue: identifier.rawValue)
        }
        else {
            largestUndimmedDetentIdentifier = nil
        }
    }

    public func set(wantsFullScreen: Bool) {
        sui_setWantsFullscreen(wantsFullScreen)
    }

    public func performAnimatedChanges(_ changes: @escaping () -> Void) {
        animateChanges(changes)
    }

    public var interactionDelegate: SUISheetPresentationControllerInteractionDelegate? {
        get {
            sui_interactionDelegate
        }
        set {
            sui_interactionDelegate = newValue
        }
    }

    public var presentationController: UIPresentationController {
        self
    }
}
