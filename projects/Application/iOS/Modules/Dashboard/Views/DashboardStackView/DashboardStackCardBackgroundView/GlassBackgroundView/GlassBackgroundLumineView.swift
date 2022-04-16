//
//  GlassBackgroundLumineView.swift
//  iOS
//
//  Created by Anton Spivak on 16.04.2022.
//

import UIKit
import HuetonUI
import SystemUI
import DeclarativeUI

class GlassBackgroundLumineView: UIView {
    
    private var cachedBounds = CGRect.zero
    private let maskingView = UIView()
    
    private var lineWidth: CGFloat = 18 {
        didSet {
            cachedBounds = .zero
            setNeedsLayout()
        }
    }
    
    private var borderWodth: CGFloat = 1 {
        didSet {
            cachedBounds = .zero
            setNeedsLayout()
        }
    }
    
    let gradientView = GradientView()
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            cachedBounds = .zero
            setNeedsLayout()
        }
    }
    
    var glowRadius: CGFloat = 3 {
        didSet {
            cachedBounds = .zero
            setNeedsLayout()
        }
    }
    
    init() {
        super.init(frame: .zero)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        gradientView.colors = [.cyan, .magenta]
        gradientView.locations = [0, 1]
        gradientView.angle = 135
        
        maskingView.layer.shadowColor = UIColor.red.cgColor
        maskingView.layer.shadowOpacity = 1
        maskingView.layer.shadowRadius = glowRadius
        maskingView.layer.shadowOffset = .zero
        
        maskingView.layer.backgroundColor = UIColor.clear.cgColor
        maskingView.layer.borderColor = UIColor.red.cgColor
        maskingView.layer.borderWidth = borderWodth
        
        addSubview(gradientView)
        gradientView.mask = maskingView
        
        let effect = GlassGradientAngleMotionEffect(gradientView: gradientView)
        addMotionEffect(effect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard layer == self.layer,
              cachedBounds != bounds
        else {
            return
        }
        
        cachedBounds = bounds
        
        gradientView.frame = CGRect(
            x: -glowRadius * 4,
            y: -glowRadius * 4,
            width: bounds.width + glowRadius * 8,
            height: bounds.height + glowRadius * 8
        )
        
        maskingView.frame = CGRect(
            x: glowRadius * 4 - borderWodth,
            y: glowRadius * 4 - borderWodth,
            width: bounds.width + borderWodth * 2,
            height: bounds.height + borderWodth * 2
        )
        
        maskingView.layer.shadowPath = path()
        maskingView.layer.cornerRadius = cornerRadius
        maskingView.layer.cornerCurve = .continuous
    }
    
    // MARK: Private
    
    private func path() -> CGPath {
        let outerPath = UIBezierPath(
            roundedRect: CGRect(
                x: borderWodth,
                y: borderWodth,
                width: bounds.width,
                height: bounds.height
            ),
            cornerRadius: cornerRadius
        )
        
        let innerPath = UIBezierPath(
            roundedRect: CGRect(
                x: lineWidth,
                y: lineWidth,
                width: bounds.width - lineWidth * 2,
                height: bounds.height - lineWidth * 2
            ),
            cornerRadius: cornerRadius
        ).reversing()
        
        outerPath.usesEvenOddFillRule = true
        outerPath.append(innerPath)
        
        return outerPath.cgPath
    }
}
