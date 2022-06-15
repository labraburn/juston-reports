//
//  CardStackCardLoadingView.swift
//  iOS
//
//  Created by Anton Spivak on 15.06.2022.
//

import UIKit
import HuetonUI

final class CardStackCardLoadingView: UIView {
    
    private var isLoading: Bool = false

    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.pin(to: 24).isActive = true
        widthAnchor.pin(to: 24).isActive = true
        backgroundColor = .clear
        
        layer.cornerRadius = 12
        layer.cornerCurve = .circular
    }
    
    func setLoading(_ flag: Bool, delay: TimeInterval = 1.2) {
        isLoading = flag
        
        if flag {
            startRotationAnimation()
            startLoadingAnimation(delay: delay)
        } else {
            stopRotationAnimation()
            stopLoadingAnimation()
        }
    }
    
    private func startRotationAnimation() {
        guard layer.animation(forKey: "rotation") == nil
        else {
            return
        }
        
        layer.add({
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = Float.pi * 2
            animation.duration = 4.2
            animation.repeatCount = .infinity
            return animation
        }(), forKey: "rotation")
    }
    
    private func stopRotationAnimation() {
        layer.removeAnimation(forKey: "rotation")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        if superview != nil && isLoading {
            startRotationAnimation()
        } else {
            stopRotationAnimation()
        }
    }
}
