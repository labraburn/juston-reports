//
//  Created by Anton Spivak.
//  

import UIKit

extension UIButton {
    
    public func insertVisualEffectViewWithEffect(
        _ effect: UIBlurEffect,
        cornerRadius: CGFloat = 0,
        cornerCurve: CALayerCornerCurve = .continuous
    ) {
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        if cornerRadius > 0 {
            visualEffectView.clipsToBounds = true
            visualEffectView.layer.cornerRadius = cornerRadius
            visualEffectView.layer.cornerCurve = .continuous
        }
        
        insertSubview(visualEffectView, at: 0)
        visualEffectView.pinned(edges: self)
        
        if let imageView = imageView {
            imageView.backgroundColor = .clear
            bringSubviewToFront(imageView)
        }
    }
}
