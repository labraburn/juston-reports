//
//  GlassBackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 15.04.2022.
//

import UIKit
import HuetonUI
import SystemUI
import DeclarativeUI

class GlassBackgroundView: UIView, CardStackCardBackgroundContentView {
    
    private let borderView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(radius: 67, scale: 100)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let lumineView: GlassBackgroundLumineView
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            lumineView.cornerRadius = cornerRadius
            visualEffectView.layer.cornerRadius = cornerRadius
        }
    }
    
    init(colors: [UIColor]) {
        lumineView = GlassBackgroundLumineView(colors: colors).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        super.init(frame: .zero)
        _init()
    }
    
    required init?(coder: NSCoder) {
        lumineView = GlassBackgroundLumineView(colors: [.cyan, .magenta]).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        lumineView.cornerRadius = cornerRadius
        addSubview(lumineView)
        
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerCurve = .continuous
        visualEffectView.layer.cornerRadius = cornerRadius
        addSubview(visualEffectView)
        
        NSLayoutConstraint.activate {
            lumineView.pin(edges: self)
            visualEffectView.pin(edges: self)
        }
    }
}
