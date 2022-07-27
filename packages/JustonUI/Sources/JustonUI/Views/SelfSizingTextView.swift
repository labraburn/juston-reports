//
//  Created by Anton Spivak.
//

import UIKit

public class SelfSizingTextView: UITextView {
    
    public var maximumContentSizeHeight: CGFloat = 36
    public var minimumContentSizeHeight: CGFloat = 36

    private var _heightAnchor: NSLayoutConstraint?
    internal weak var layoutContainerView: UIView?

    public override var contentSize: CGSize {
        didSet {
            if _heightAnchor == nil {
                _heightAnchor = heightAnchor.constraint(equalToConstant: contentSize.height)
                _heightAnchor?.priority = .required - 1
                _heightAnchor?.isActive = true
            }
            
            let animate = (_heightAnchor?.constant ?? 0) != contentSize.height
            _heightAnchor?.constant = estimateHeight(contentSize.height)
            
            setNeedsLayout()
            if animate {
                UIView.animate(
                    withDuration: 0.42,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.1,
                    options: [.curveEaseInOut],
                    animations: {
                        switch self.layoutContainerView {
                        case is UICollectionView:
                            (self.layoutContainerView as? UICollectionView)?.collectionViewLayout.invalidateLayout()
                        default:
                            break
                        }
                        
                        self.layoutContainerView?.layoutIfNeeded()
                        self.superview?.layoutIfNeeded()
                        self.layoutIfNeeded()
                    },
                    completion: nil
                )
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height = estimateHeight(intrinsicContentSize.height)
        return intrinsicContentSize
    }
    
    public override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        var systemLayoutSizeFitting = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        systemLayoutSizeFitting.height = estimateHeight(systemLayoutSizeFitting.height)
        return systemLayoutSizeFitting
    }
    
    private func estimateHeight(_ height: CGFloat) -> CGFloat {
        min(max(minimumContentSizeHeight, height), maximumContentSizeHeight)
    }
}
