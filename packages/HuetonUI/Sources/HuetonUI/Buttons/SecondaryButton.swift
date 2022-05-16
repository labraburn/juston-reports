//
//  Created by Anton Spivak.
//

import UIKit

public class SecondaryButton: UIControl {
    
    private let borderView = GradientBorderedView(colors: [UIColor(rgb: 0x4876E6), UIColor(rgb: 0x8D55E9)]).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.cornerRadius = 12
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = UIColor(rgb: 0x7B66FF)
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
        
        addSubview(borderView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            borderView.pin(edges: self)
            textLabel.pin(edges: self)
        })
        
        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .medium)
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
