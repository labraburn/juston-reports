//
//  SteppableButtonCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class SteppableButtonCell: UICollectionViewCell {
    
    struct Model: Equatable {
        
        let title: String?
        let kind: SteppableItem.ButtonKind
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
            if isHighlighted {
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
