//
//  PasscodeDotView.swift
//  iOS
//
//  Created by Anton Spivak on 11.04.2022.
//

import UIKit
import HuetonCORE

class PasscodeDotView: UIView {
    
    private let innerView: UIView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
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
        
        innerView.layer.cornerRadius = innerView.bounds.height / 2
        innerView.layer.cornerCurve = .continuous
        
        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve = .circular
    }
    
    var filled: Bool = false {
        didSet {
            if filled {
                innerView.alpha = 1
                innerView.backgroundColor = tintColor
            } else {
                innerView.alpha = 0
                innerView.backgroundColor = .clear
            }
        }
    }
    
    private func initialize() {
        addSubview(innerView)
        NSLayoutConstraint.activate({
            innerView.pin(edges: self, insets: UIEdgeInsets(top: 6, left: 6, right: 6, bottom: 6))
        })
    }
}
