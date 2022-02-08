//
//  Created by Anton Spivak
//

import UIKit

internal class SearchTextField: UITextField {
    var padding: UIEdgeInsets = .zero

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let scrollView = subviews.first as? UIScrollView
        else {
            return
        }

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentOffset = CGPoint(
            x: scrollView.contentOffset.x,
            y: 0
        )
    }
}
