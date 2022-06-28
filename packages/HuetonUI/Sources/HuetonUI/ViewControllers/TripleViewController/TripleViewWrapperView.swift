//
//  Created by Anton Spivak
//

import UIKit

internal final class TripleViewWrapperView: UIView {
    
    private class Layer: CALayer {
        
        override var bounds: CGRect {
            set {
                // Handle UIViewPropertyAnimator strange bug
                var newValue = newValue
                newValue.origin = .zero
                super.bounds = newValue
            }
            get {
                super.bounds
            }
        }
    }
    
    enum PinnedPosition {
        
        case top(size: CGSize)
        case bottom(size: CGSize)
        case fill(insets: UIEdgeInsets)
    }
    
    let subview: UIView
    
    override class var layerClass: AnyClass { Layer.self }
    
    var pinnedPosition: PinnedPosition = .top(size: .zero) {
        didSet {
            setNeedsLayout()
        }
    }
    
    init(_ subview: UIView) {
        self.subview = subview
        
        super.init(
            frame: .zero
        )
        
        addSubview(subview)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch pinnedPosition {
        case let .top(size):
            subview.frame = CGRect(
                origin: .zero,
                size: size
            )
        case let .bottom(size):
            subview.frame = CGRect(
                origin: CGPoint(
                    x: 0,
                    y: bounds.height - size.height
                ),
                size: size
            )
        case let .fill(insets):
            subview.frame = bounds.inset(
                by: insets
            )
        }
    }
}
