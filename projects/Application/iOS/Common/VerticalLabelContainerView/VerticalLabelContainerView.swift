//
//  VerticalLabelContainerView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit

final class VerticalLabelContainerView: UIView {
    
    let label: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(label)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.bounds = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.width)
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        label.transform = .identity.rotated(by: .pi / 2)
    }
    
    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = label.intrinsicContentSize
        return CGSize(width: intrinsicContentSize.height, height: intrinsicContentSize.width)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let systemLayoutSizeFitting = label.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        return CGSize(width: systemLayoutSizeFitting.height, height: systemLayoutSizeFitting.width)
    }
}
