//
//  C42ButtonCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class C42ButtonCell: UICollectionViewCell {
    
    struct Model: Equatable {
        
        let title: String?
        let kind: C42Item.ButtonKind
    }
    
    var model: Model? = nil {
        didSet {
            guard oldValue != model
            else {
                return
            }
            
            switch model?.kind {
            case .primary:
                button = PrimaryButton(title: model?.title)
            case .secondary:
                button = SecondaryButton(title: model?.title)
            case .teritary:
                button = TeritaryButton(title: model?.title)
            case .none:
                button = nil
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            button?.setHighlightedAnimated(isHighlighted)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                button?.impactOccurred()
            }
        }
    }
    
    private var button: HuetonButton? = nil {
        didSet {
            button?.removeFromSuperview()
            guard let button = button
            else {
                return
            }
            
            contentView.addSubview(button)
            
            button.isUserInteractionEnabled = false
            button.translatesAutoresizingMaskIntoConstraints = false
            button.pinned(edges: contentView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAsynchronousOperation(
        priority: TaskPriority? = nil,
        _ block: @escaping @Sendable () async -> ()
    ) {
        button?.startAsynchronousOperation(
            priority: priority,
            block,
            { [weak button] in
                button?.isUserInteractionEnabled = false
            }
        )
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
