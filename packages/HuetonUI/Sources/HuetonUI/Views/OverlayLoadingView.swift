//
//  Created by Anton Spivak.
//

import UIKit

public final class OverlayLoadingView: UIView {
    
    private let gradientView: GradientView = GradientView()
    private let gradientMaskView: OverlayLoadingViewMaskView = OverlayLoadingViewMaskView()
    
    private var isAnimationInProgress: Bool = false
    
    public var cornerRadius: CGFloat = 10
    public var cornerCurve: CALayerCornerCurve = .continuous
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        addSubview(gradientView)
        gradientView.mask = gradientMaskView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskView.frame = bounds
        gradientMaskView.cornerRadius = cornerRadius
        gradientMaskView.cornerCurve = cornerCurve
        gradientView.frame = bounds
    }
    
    public func startAnimation(delay: TimeInterval = 0.0) {
        guard !isAnimationInProgress
        else {
            return
        }
        
        alpha = 0
        isUserInteractionEnabled = true
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: delay, options: .beginFromCurrentState, animations: {
            self.alpha = 1
            self.gradientMaskView.animate(with: 1.0)
        }, completion: nil)
    }
    
    public func stopAnimation(completion: (() -> ())?) {
        guard isAnimationInProgress
        else {
            completion?()
            return
        }
        
        // Animation doesn't start yet
        if layer.presentation()?.opacity != 0 {
            layer.removeAllAnimations()
            
            alpha = 0
            completion?()
            
            return
        }
        
        // Animation in progress right now
        if let presentationLayer = layer.presentation(), presentationLayer.opacity < 0 {
            let opacity = presentationLayer.opacity
            layer.removeAllAnimations()
            layer.opacity = opacity
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 0
        }, completion: { finished in
            self.alpha = 0
            self.isAnimationInProgress = false
            completion?()
        })
    }
}

extension OverlayLoadingView: OverlayLoadingViewMaskViewDelegate {
    
    fileprivate func overlayLoadingViewMaskViewShouldRestartAnimation(_ view: OverlayLoadingViewMaskView) -> Bool {
        return isAnimationInProgress
    }
}

// MARK: LoadingWindowViewMaskViewDelegate
fileprivate protocol OverlayLoadingViewMaskViewDelegate: AnyObject {
    
    func overlayLoadingViewMaskViewShouldRestartAnimation(_ view: OverlayLoadingViewMaskView) -> Bool
}

// MARK: LoadingWindowViewMaskView
fileprivate class OverlayLoadingViewMaskView: UIView {
    
    override class var layerClass: AnyClass { CAShapeLayer.self }
    
    var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    var animationDuration: TimeInterval = 1
    
    var cornerRadius: CGFloat = 10
    var cornerCurve: CALayerCornerCurve = .continuous
    
    weak var delegate: OverlayLoadingViewMaskViewDelegate? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = self.cornerRadius == 0 ? 4 : self.cornerRadius
        shapeLayer.path = path(frame: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        shapeLayer.lineJoin = .round
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
    }
    
    func animate(with duration: TimeInterval) {
        animationDuration = duration
        
        let inAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            return animation
        }()
         
        let outAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeStart")
            animation.beginTime = duration / 2
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name:  CAMediaTimingFunctionName.easeOut)
            return animation
        }()
    
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = duration + outAnimation.beginTime
        strokeAnimationGroup.repeatCount = 1
        strokeAnimationGroup.animations = [inAnimation, outAnimation]
        strokeAnimationGroup.delegate = self
        
        layer.add(strokeAnimationGroup, forKey: "strokeAnimation")
    }
    
    private func path(frame: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width / 2.0, y: 0))
        
        path.addLine(to: CGPoint(x: frame.width - cornerRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: frame.width, y: frame.height-cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: cornerRadius, y: frame.height))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: .pi * 3 / 2,
            clockwise: true
        )
        
        path.close()
        path.apply(CGAffineTransform(translationX: frame.origin.x, y: frame.origin.y))

        return path;
    }
}

extension OverlayLoadingViewMaskView: CAAnimationDelegate {
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        var delegateShouldRestart = true
        if let delegate = delegate {
            delegateShouldRestart = delegate.overlayLoadingViewMaskViewShouldRestartAnimation(self)
        }
        
        guard flag && delegateShouldRestart
        else {
            return
        }
        
        animate(with: animationDuration)
    }
}
