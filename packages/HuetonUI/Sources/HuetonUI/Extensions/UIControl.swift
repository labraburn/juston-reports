//
//  Created by Anton Spivak.
//  

import UIKit

extension UIControl {
    
    public override func insertFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        super.insertFeedbackGenerator(style: style)
        addTarget(self, action: #selector(_touchUpInsideWithFeedbackOccurred), for: .touchUpInside)
    }
    
    public override func insertHighlightingScaleDownAnimation(_ scale: CGFloat = 0.96) {
        super.insertHighlightingScaleDownAnimation(scale)
        
        addTarget(self, action: #selector(_touchDown), for: .touchDown)
        
        addTarget(self, action: #selector(_touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(_touchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(_touchUp), for: .touchDragExit)
        addTarget(self, action: #selector(_touchUp), for: .touchDragOutside)
    }
    
    @objc
    private func _touchDown() {
        setScaledDown(true)
    }
    
    @objc
    private func _touchUp() {
        setScaledDown(false)
    }
    
    @objc
    private func _touchUpInsideWithFeedbackOccurred() {
        impactOccurred()
    }
}
