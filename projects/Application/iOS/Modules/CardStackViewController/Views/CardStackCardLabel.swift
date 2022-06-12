//
//  CardStackCardLabel.swift
//  iOS
//
//  Created by Anton Spivak on 12.06.2022.
//

import UIKit
import HuetonUI

final class CardStackCardLabel: UIButton {

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
    
    static func createTopButton(_ text: String) -> UIButton {
        let button = CardStackCardLabel(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.insertHighlightingScaleAnimation()
        button.insertFeedbackGenerator(style: .medium)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .font(for: .caption2)
        button.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        return button
    }
}
