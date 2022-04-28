//
//  GradientImageBackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 16.04.2022.
//

import UIKit
import HuetonUI

class GradientImageBackgroundView: UIView, CardStackCardBackgroundContentView {
    
    private let imageView: UIImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleToFill
        $0.clipsToBounds = true
    })
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.cornerCurve = .continuous
            
            setNeedsLayout()
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
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
        addSubview(imageView)
        imageView.pinned(edges: self)
        
        clipsToBounds = false
        
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(rgb: 0x9341F9).cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(rgb: 0xFEF6FF).withAlphaComponent(0.1).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
}
