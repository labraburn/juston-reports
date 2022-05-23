//
//  Created by Anton Spivak.
//

import UIKit

public class HuetonButton: UIControl {
    
    private var task: Task<(), Never>? = nil
    
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
        task?.cancel()
    }
    
    // MARK: Operations
    
    public func startAsynchronousOperation(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> ()
    ) {
        guard task == nil
        else {
            return
        }
        
        startLoadingAnimation(delay: 0.2)
        task = Task { [weak self] in
            await operation()
            
            self?.stopLoadingAnimation()
            self?.task = nil
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
