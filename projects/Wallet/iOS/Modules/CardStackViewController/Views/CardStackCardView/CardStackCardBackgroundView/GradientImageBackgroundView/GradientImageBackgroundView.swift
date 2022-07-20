//
//  GradientImageBackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 16.04.2022.
//

import UIKit
import JustonUI

class GradientImageBackgroundView: UIView, CardStackCardBackgroundContentView {
    
    private let imageView: UIImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleToFill
        $0.clipsToBounds = true
    })
    
    var borderColor: UIColor = .white.withAlphaComponent(0) {
        didSet {
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = borderColor.cgColor
            setNeedsLayout()
        }
    }
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
}
