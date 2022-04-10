//
//  PasscodeNumberButton.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonCORE

class PasscodeNumberButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve = .circular
    }
    
    private func initialize() {
        layer.masksToBounds = true
        titleLabel?.font = .font(for: .title2)
        insertFeedbackGenerator(style: .light)
        insertVisualEffectViewWithEffect(UIBlurEffect(style: .light))
        insertHighlightingScaleDownAnimation()
    }
}
