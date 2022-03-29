//
//  Created by Anton Spivak.
//  

import ObjectiveC
import UIKit

extension UIView {
    
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
    
    // MARK: API
    
    @objc
    public func insertFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: style)
    }
    
    @objc
    public func insertHighlightingScaleDownAnimation(_ scale: CGFloat = 0.96) {
        self.scale = scale
    }
    
    public func impactOccurred() {
        feedbackGenerator?.impactOccurred()
    }
    
    public func setScaledDown(_ scaledDown: Bool) {
        if scaledDown {
            hui_down()
        } else {
            hui_up()
        }
    }
    
    // MARK: Private
    
    private func hui_up() {
        if animator?.isRunning ?? false {
            let item = DispatchWorkItem(block: { [weak self] in
                self?.hui_upWithoutDelay()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: item)
            delayed = Block(item)
        } else {
            hui_upWithoutDelay()
        }
    }
    
    private func hui_upWithoutDelay() {
        let timing = UISpringTimingParameters(damping: 0.4, response: 0.3)
        
        animator = UIViewPropertyAnimator(duration: 0.25, timingParameters: timing)
        animator?.addAnimations({
            self.transform = .identity
        })
        
        animator?.startAnimation()
        delayed = nil
    }
    
    private func hui_down() {
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
}
