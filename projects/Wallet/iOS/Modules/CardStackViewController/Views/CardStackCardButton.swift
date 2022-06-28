//
//  CardStackCardButton.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI

final class CardStackCardButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.applyFigmaShadow(
            color: .init(rgb: 0x232020),
            alpha: 0.24,
            x: 0,
            y: 12,
            blur: 12,
            spread: 0,
            cornerRadius: 10
        )
    }
    
    static func createBottomButton(_ image: UIImage) -> UIButton {
        let button = CardStackCardButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.insertHighlightingScaleAnimation()
        button.insertFeedbackGenerator(style: .medium)
        
        // Inside UIStackView this helps tp avoid unnecessary errors
        let constraint = button.widthAnchor.pin(to: button.heightAnchor)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 26
        button.layer.cornerCurve = .continuous
        return button
    }
}
