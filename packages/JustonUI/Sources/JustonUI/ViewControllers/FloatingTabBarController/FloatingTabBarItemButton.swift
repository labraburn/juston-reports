//
//  Created by Anton Spivak
//

import UIKit

internal final class FloatingTabBarItemButton: UIControl {
    
    internal weak var view: UIControl? {
        didSet {
            oldValue?.removeFromSuperview()
            view?.isUserInteractionEnabled = false

            guard let view = view
            else {
                return
            }

            addSubview(view)
            setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            view?.tintColor = tintColor
        }
    }
    
    var selectedTintColor: UIColor?
    var deselectedTintColor: UIColor?

    override var isAccessibilityElement: Bool {
        get { true }
        set { _ = newValue }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var traits = UIAccessibilityTraits.button
            if isSelected {
                traits = UIAccessibilityTraits(rawValue: traits.rawValue | UIAccessibilityTraits.selected.rawValue)
            }
            return traits
        }
        set { _ = newValue }
    }

    override var isSelected: Bool {
        get { super.isSelected }
        set {
            if isSelected && isSelected != newValue {
                impactOccurred()
            }
            
            tintColor = newValue ? selectedTintColor : deselectedTintColor
            
            super.isSelected = newValue
            view?.isSelected = newValue
        }
    }

    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            super.isHighlighted = newValue
            view?.isHighlighted = newValue
            
            setHighlightedAnimated(newValue)
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        insertFeedbackGenerator(style: .light)
        insertHighlightingScaleAnimation(0.96)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view?.frame = bounds
    }
}
