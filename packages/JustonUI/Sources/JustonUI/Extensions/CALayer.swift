//
//  Created by Anton Spivak.
//  

import UIKit

extension CALayer {
    
    public func applyFigmaShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat,
        cornerRadius: CGFloat
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        
        if spread == 0 {
            shadowPath = nil
        } else {
            let d = -spread
            let rect = bounds.insetBy(dx: d, dy: d)
            if cornerRadius > 0 {
                shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
            } else {
                shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
    }
    
    public func recursivelyRemoveAllAnimations() {
        removeAllAnimations()
        sublayers?.forEach({ $0.recursivelyRemoveAllAnimations() })
    }
}
