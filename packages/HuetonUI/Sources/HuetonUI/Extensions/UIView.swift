//
//  Created by Anton Spivak.
//  

import ObjectiveC
import UIKit

//
// Scale down/up animation
//

extension UIView {
    
    private enum Keys {
        
        static var animator: UInt8 = 0
        
        static var scaleHighlightAnimationValue: UInt8 = 0
        static var alphaHighlightAnimationValue: UInt8 = 0
        
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
    
    private var scaleHighlightAnimationValue: CGFloat? {
        get {
            objc_getAssociatedObject(self, &Keys.scaleHighlightAnimationValue) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &Keys.scaleHighlightAnimationValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var alphaHighlightAnimationValue: CGFloat? {
        get {
            objc_getAssociatedObject(self, &Keys.alphaHighlightAnimationValue) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &Keys.alphaHighlightAnimationValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    public func insertHighlightingScaleAnimation(_ scale: CGFloat = 0.96) {
        self.scaleHighlightAnimationValue = scale
    }
    
    @objc
    public func insertHighlightingAlphaAnimation(_ alpha: CGFloat = 0.64) {
        self.alphaHighlightAnimationValue = alpha
    }
    
    public func impactOccurred() {
        feedbackGenerator?.impactOccurred()
    }
    
    public func setHighlightedAnimated(_ highlighted: Bool) {
        if highlighted {
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
            self.alpha = 1
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
            if let scale = self.scaleHighlightAnimationValue {
                self.transform = .init(scaleX: scale, y: scale)
            }
            if let alpha = self.alphaHighlightAnimationValue {
                self.alpha = alpha
            }
        })
        
        animator?.startAnimation()
    }
}

//
// Shake animation
//

extension UIView {
    
    public func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

//
// Loading animation
//

extension UIView {
    
    private static let overlayLoadingViewTag = 0x0f56
    
    public func startLoadingAnimation(delay: TimeInterval = 0.2) {
        isUserInteractionEnabled = false
        
        var view = viewWithTag(UIView.overlayLoadingViewTag) as? OverlayLoadingView
        if view == nil {
            let loadingView = OverlayLoadingView()
            loadingView.tag = UIView.overlayLoadingViewTag
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingView.cornerRadius = layer.cornerRadius
            loadingView.cornerCurve = layer.cornerCurve
            
            addSubview(loadingView)
            loadingView.pinned(edges: self)
            
            view = loadingView
        }
        
        view?.startAnimation(delay: delay)
    }
    
    public func stopLoadingAnimation() {
        isUserInteractionEnabled = true
        
        let view = viewWithTag(UIView.overlayLoadingViewTag) as? OverlayLoadingView
        view?.stopAnimation(completion: {
            view?.removeFromSuperview()
        })
    }
}
