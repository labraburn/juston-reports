//
//  BackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 05.02.2022.
//

import UIKit

@IBDesignable
class BackgroundView: UIView {
    
    private let imageView = UIImageView()
    
    @IBInspectable
    var isParallaxEnabled: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        _init()
    }
    
    private func _init() {
        imageView.image = UIImage(named: "Stars")
        imageView.contentMode = .scaleAspectFill
        
        let amount = 42
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        
        if isParallaxEnabled {
            imageView.addMotionEffect(group)
        }
        
        addSubview(imageView)
        backgroundColor = .bui_backgroundPrimary
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
