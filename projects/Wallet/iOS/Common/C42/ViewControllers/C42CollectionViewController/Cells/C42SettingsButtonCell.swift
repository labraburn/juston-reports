//
//  C42SettingsButtonCell.swift
//  iOS
//
//  Created by Anton Spivak on 02.06.2022.
//

import UIKit
import JustonUI

class C42SettingsButtonCell: UICollectionViewCell {
    
    struct Model: Equatable {
        
        let title: String?
        let titleColor: UIColor
    }
    
    var model: Model? = nil {
        didSet {
            guard oldValue != model
            else {
                return
            }
            
            button.title = model?.title
            button.titleColor = model?.titleColor ?? .white
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            button.setHighlightedAnimated(isHighlighted)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.impactOccurred()
            }
        }
    }
    
    private var button: SecondaryButton = SecondaryButton().with({
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        button.pinned(edges: contentView)
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
