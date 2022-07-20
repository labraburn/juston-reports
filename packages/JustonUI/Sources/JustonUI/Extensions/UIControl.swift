//
//  Created by Anton Spivak.
//  

import UIKit

extension UIControl {
    
    public override func insertFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        super.insertFeedbackGenerator(style: style)
        addTarget(self, action: #selector(_touchUpInsideWithFeedbackOccurred), for: .touchUpInside)
    }
    
    public override func insertHighlightingScaleAnimation(_ scale: CGFloat = 0.96) {
        super.insertHighlightingScaleAnimation(scale)
        insertTargetActionIfNeeded()
    }
    
    public override func insertHighlightingAlphaAnimation(_ alpha: CGFloat = 0.96) {
        super.insertHighlightingAlphaAnimation(alpha)
        insertTargetActionIfNeeded()
    }
    
    private func insertTargetActionIfNeeded() {
        guard !allTargets.contains(self)
        else {
            return
        }
        
        addTarget(self, action: #selector(_touchDown), for: .touchDown)
        
        addTarget(self, action: #selector(_touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(_touchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(_touchUp), for: .touchDragExit)
        addTarget(self, action: #selector(_touchUp), for: .touchDragOutside)
        addTarget(self, action: #selector(_touchUp), for: .touchCancel)
    }
    
    @objc
    private func _touchDown() {
        setHighlightedAnimated(true)
    }
    
    @objc
    private func _touchUp() {
        setHighlightedAnimated(false)
    }
    
    @objc
    private func _touchUpInsideWithFeedbackOccurred() {
        impactOccurred()
    }
}
