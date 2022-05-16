//
//  Created by Anton Spivak.
//

import UIKit

public final class PrimaryButton: UIButton {
    
    private let gradientView = GradientView(colors: [UIColor(rgb: 0x4776E6), UIColor(rgb: 0x8E54E9)], angle: 45).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
    })
    
    public var title: String = "" {
        didSet {
            textLabel.text = title
        }
    }
    
    public init(title: String) {
        super.init(frame: .zero)
        textLabel.text = title
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        
        clipsToBounds = true
        
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        
        addSubview(gradientView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            gradientView.pin(edges: self)
            textLabel.pin(edges: self)
        })
        
        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .heavy)
    }
    
    public override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height = 60
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
        systemLayoutSizeFitting.height = 60
        return systemLayoutSizeFitting
    }
}
