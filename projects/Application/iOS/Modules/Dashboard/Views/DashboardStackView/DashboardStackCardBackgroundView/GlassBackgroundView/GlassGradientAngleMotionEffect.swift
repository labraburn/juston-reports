//
//  GlassGradientAngleMotionEffect.swift
//  iOS
//
//  Created by Anton Spivak on 16.04.2022.
//

import UIKit
import HuetonUI

class GlassGradientAngleMotionEffect: UIMotionEffect {
    
    private(set) weak var gradientView: GradientView? = nil
    
    init(gradientView: GradientView) {
        self.gradientView = gradientView
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPathsAndRelativeValues(forViewerOffset viewerOffset: UIOffset) -> [String : Any]? {
        guard let gradientView = gradientView
        else {
            return nil
        }

        let p1 = CGPoint(x: viewerOffset.horizontal, y: viewerOffset.vertical)
        let p2 = CGPoint(x: 1, y: 0)

        let dY = p1.y - p2.y
        let dX = p2.x - p1.x
        var angle = atan2(dY, dX) * 180 / .pi
        
        if angle < 0 {
            angle += 360
        }
        
        UIView.animate(withDuration: 1.42, delay: 0, options: [.curveEaseOut], animations: {
            gradientView.angle = angle
        }, completion: nil)
        
        return nil
    }
}
