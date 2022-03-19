//
//  Created by Anton Spivak.
//  

import ObjectiveC
import UIKit

extension UIControl {
    
    private enum Keys {
        
        static var animator: UInt8 = 0
        static var scale: UInt8 = 0
        static var delayed: UInt8 = 0
        static var generator: UInt8 = 0
    }
    
    private class Block {
        
        let item: DispatchWorkItem
        
        init(_ item: DispatchWorkItem) {
            self.item = item
        }
    }
    
    private var animator: UIViewPropertyAnimator? {
        get {
            if let animator = objc_getAssociatedObject(self, &Keys.animator) as? UIViewPropertyAnimator {
                return animator
            } else {
                return nil
            }
        }
        set {
            objc_setAssociatedObject(self, &Keys.animator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var scale: CGFloat {
        get {
            if let animationScale = objc_getAssociatedObject(self, &Keys.scale) as? CGFloat {
                return animationScale
            } else {
                return 0.96
            }
        }
        set {
            objc_setAssociatedObject(self, &Keys.scale, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var delayed: Block? {
        get {
            objc_getAssociatedObject(self, &Keys.delayed) as? Block
        }
        set {
            objc_setAssociatedObject(self, &Keys.delayed, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var feedbackGenerator: UIImpactFeedbackGenerator? {
        get {
            objc_getAssociatedObject(self, &Keys.generator) as? UIImpactFeedbackGenerator
        }
        set {
            objc_setAssociatedObject(self, &Keys.generator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func insertFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        addTarget(self, action: #selector(_touchUpInside), for: .touchUpInside)
    }
    
    public func insertHighlightingScaleDownAnimation(_ scale: CGFloat = 0.96) {
        self.scale = scale
        
        addTarget(self, action: #selector(_touchDown), for: .touchDown)
        
        addTarget(self, action: #selector(_touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(_touchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(_touchUp), for: .touchDragExit)
        addTarget(self, action: #selector(_touchUp), for: .touchDragOutside)
    }
    
    @objc
    private func _touchDown() {
        delayed?.item.cancel()
        delayed = nil
        
        animator?.stopAnimation(true)
        
        let timing = UISpringTimingParameters(damping: 0.4, response: 0.1)
        
        animator = UIViewPropertyAnimator(duration: 0.12, timingParameters: timing)
        animator?.addAnimations({
            self.transform = .init(scaleX: self.scale, y: self.scale)
        })
        
        animator?.startAnimation()
    }
    
    @objc
    private func _touchUp() {
        if animator?.isRunning ?? false {
            let item = DispatchWorkItem(block: { [weak self] in
                self?._touchUpRightNow()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: item)
            delayed = Block(item)
        } else {
            _touchUpRightNow()
        }
    }
    
    @objc
    private func _touchUpInside() {
        feedbackGenerator?.impactOccurred()
    }
    
    private func _touchUpRightNow() {
        let timing = UISpringTimingParameters(damping: 0.4, response: 0.3)
        
        animator = UIViewPropertyAnimator(duration: 0.25, timingParameters: timing)
        animator?.addAnimations({
            self.transform = .identity
        })
        
        animator?.startAnimation()
        delayed = nil
    }
}
