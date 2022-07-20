//
//  GlassBackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 15.04.2022.
//

import UIKit
import JustonUI

class GlassBackgroundView: UIView, CardStackCardBackgroundContentView {
    
    enum EffectsSize {
        
        case small
        case large
        
        fileprivate var blurEffect: UIBlurEffect {
            switch self {
            case .small: return UIBlurEffect(radius: 10, scale: 100)
            case .large: return UIBlurEffect(radius: 67, scale: 100)
            }
        }
        
        fileprivate var lineWidth: CGFloat {
            switch self {
            case .small: return 6
            case .large: return 18
            }
        }
    }
    
    private lazy var borderView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var visualEffectView = UIVisualEffectView(effect: effectsSize.blurEffect).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let lumineView: GlassBackgroundLumineView
    private let effectsSize: EffectsSize
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            lumineView.cornerRadius = cornerRadius
            visualEffectView.layer.cornerRadius = cornerRadius
        }
    }
    
    init(
        colors: [UIColor],
        effectsSize: EffectsSize = .large
    ) {
        self.effectsSize = effectsSize
        lumineView = GlassBackgroundLumineView(
            colors: colors,
            lineWidth: effectsSize.lineWidth
        ).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        super.init(frame: .zero)
        _init()
    }
    
    required init?(
        coder: NSCoder
    ) {
        self.effectsSize = .large
        lumineView = GlassBackgroundLumineView(
            colors: [.cyan, .magenta],
            lineWidth: EffectsSize.large.lineWidth
        ).with({
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
