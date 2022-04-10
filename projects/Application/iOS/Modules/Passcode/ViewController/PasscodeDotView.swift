//
//  PasscodeDotView.swift
//  iOS
//
//  Created by Anton Spivak on 11.04.2022.
//

import UIKit
import HuetonCORE

class PasscodeDotView: UIView {
    
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
    
    var filled: Bool = false {
        didSet {
            if filled {
                backgroundColor = tintColor
                layer.borderColor = nil
                layer.borderWidth = 0
            } else {
                backgroundColor = .clear
                layer.borderColor = tintColor.cgColor
                layer.borderWidth = 1
            }
        }
    }
    
    private func initialize() {
        insertHighlightingScaleDownAnimation()
    }
}
