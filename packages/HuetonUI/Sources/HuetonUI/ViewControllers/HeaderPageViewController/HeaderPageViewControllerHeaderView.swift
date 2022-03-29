//
//  Created by Anton Spivak
//

import UIKit
import SystemUI

internal final class HeaderPageViewControllerHeaderView: UIView {
    var wrappedView: UIView? {
        didSet {
            guard oldValue != wrappedView
            else {
                return
            }

            oldValue?.removeFromSuperview()

            guard let newValue = wrappedView
            else {
                return
            }

            newValue.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newValue)

            newValue.topAnchor.constraint(equalTo: topAnchor).isActive = true
            newValue.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            newValue.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            newValue.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
    }

    var wrappedViewTargetSize: CGSize {
        guard let wrappedView = wrappedView
        else {
            return .zero
        }

        var targetSize = bounds.size
        targetSize.height = UIView.layoutFittingCompressedSize.height

        return wrappedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    func overrideNextResponder(with responder: UIResponder?) {
        sui_overrideNextResponder(with: responder, for: .touches)

        let view = responder as? UIView
        sui_overridenGestureRecognizersParent = view
    }

    override var intrinsicContentSize: CGSize {
        guard wrappedView != nil
        else {
            return .zero
        }

        return CGSize(
            width: UIView.layoutFittingExpandedSize.width,
            height: UIView.layoutFittingCompressedSize.height
        )
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        guard let wrappedView = wrappedView
        else {
            return .zero
        }

        return wrappedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
}
