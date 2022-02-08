//
//  Created by Anton Spivak.
//  

import UIKit

open class MagicLabel: UIView {
    
    private let backgroundView: MagicBackgroundView = MagicBackgroundView(effect: UIBlurEffect(style: .systemThinMaterialLight))
    
    public let backingLabel: UILabel
    
    open class var labelClass: UILabel.Type { UILabel.self }
    
    open var text: String? {
        set {
            backingLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
        get { backingLabel.text }
    }
    
    open var attributedText: NSAttributedString? {
        set {
            backingLabel.attributedText = newValue
            invalidateIntrinsicContentSize()
        }
        get { backingLabel.attributedText }
    }
    
    open var numberOfLines: Int {
        set {
            backingLabel.numberOfLines = newValue
            invalidateIntrinsicContentSize()
        }
        get { backingLabel.numberOfLines }
    }
    
    open var font: UIFont {
        set {
            backingLabel.font = newValue
            invalidateIntrinsicContentSize()
        }
        get { backingLabel.font }
    }
    
    open var textAlignment: NSTextAlignment {
        set {
            backingLabel.textAlignment = newValue
            invalidateIntrinsicContentSize()
        }
        get { backingLabel.textAlignment }
    }
    
    open var effect: UIVisualEffect? {
        set { backgroundView.effect = newValue }
        get { backgroundView.effect }
    }
    
    open var color: UIColor {
        set {
            #if !targetEnvironment(simulator)
            backgroundView.color = newValue
            #else
            backingLabel.textColor = newValue
            #endif
        }
        get {
            #if !targetEnvironment(simulator)
            backgroundView.color
            #else
            backingLabel.textColor
            #endif
        }
    }
    
    public convenience init(effect: UIVisualEffect?) {
        self.init(frame: .zero)
        self.effect = effect
    }
    
    public override init(frame: CGRect) {
        backingLabel = Self.labelClass.init(frame: frame)
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        backingLabel = Self.labelClass.init(frame: .zero)
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        numberOfLines = 0
        backingLabel.font = .systemFont(ofSize: 34, weight: .bold)
        backingLabel.textColor = .label
        backingLabel.textAlignment = .center
        
        #if !targetEnvironment(simulator)
        addSubview(backgroundView)
        backgroundView.mask = backingLabel
        backgroundView.effect = effect
        #else
        addSubview(backingLabel)
        #endif
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        backingLabel.frame = backgroundView.bounds
    }
    
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
    }
    
    // MARK: System Layout Support
    
    open override func sizeToFit() {
        super.sizeToFit()
        backingLabel.sizeToFit()
    }
    
    open override var intrinsicContentSize: CGSize {
        let systemLayoutSizeFitting = systemLayoutSizeFitting(bounds.size, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultHigh)
        return systemLayoutSizeFitting
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = backingLabel.sizeThatFits(size)
        return sizeThatFits
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        let systemLayoutSizeFitting = backingLabel.systemLayoutSizeFitting(targetSize)
        return systemLayoutSizeFitting
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let systemLayoutSizeFitting = backingLabel.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: horizontalFittingPriority)
        return systemLayoutSizeFitting
    }
}
