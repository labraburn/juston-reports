//
//  Created by Anton Spivak.
//

import UIKit

public class HuetonButton: UIControl {
    
    public private(set) var operation: Task<(), Never>? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _initialize()
    }
    
    internal func _initialize() {
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        
        insertHighlightingScaleAnimation()
    }
    
    deinit {
        operation?.cancel()
    }
    
    // MARK: Operations
    
    public func startAsynchronousOperation(
        priority: TaskPriority? = nil,
        _ block: @escaping @Sendable () async -> ()
    ) {
        guard operation == nil
        else {
            return
        }
        
        startLoadingAnimation(delay: 0.2)
        operation = Task { [weak self] in
            await block()
            
            self?.stopLoadingAnimation()
            self?.operation = nil
        }
    }
    
    // MARK: Sizing
    
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
