//
//  Created by Anton Spivak.
//

import UIKit

public final class OverlayLoadingView: UIView {
    
    private let gradientView: GradientView = GradientView(colors: [.hui_letter_purple, .hui_letter_violet], angle: 45)
    private let gradientMaskView: OverlayLoadingViewMaskView = OverlayLoadingViewMaskView()
    
    private var isAnimationInProgress: Bool = false
    
    public var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    public var cornerCurve: CALayerCornerCurve = .continuous {
        didSet {
            layer.cornerCurve = cornerCurve
        }
    }
    
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
        backgroundColor = .clear
        
        addSubview(gradientView)
        gradientView.mask = gradientMaskView
        
        cornerRadius = 12
        cornerCurve = .continuous
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskView.frame = bounds
        gradientMaskView.cornerRadius = cornerRadius
        gradientMaskView.cornerCurve = cornerCurve
        gradientView.frame = bounds
    }
    
    public func startAnimation(delay: TimeInterval = 0.0, fade: Bool = true, width: CGFloat = 1) {
        guard !isAnimationInProgress
        else {
            return
        }
        
        alpha = 0
        isUserInteractionEnabled = true
        isAnimationInProgress = true
        gradientMaskView.lineWidth = width
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: delay, options: .beginFromCurrentState, animations: {
            self.alpha = 1
            self.backgroundColor = fade ? .black.withAlphaComponent(0.8) : .clear
            self.gradientMaskView.animate(with: 1.2)
        }, completion: nil)
    }
    
    public func stopAnimation(completion: (() -> ())?) {
        guard isAnimationInProgress
        else {
            completion?()
            return
        }
        
        // Animation doesn't start yet
        if layer.presentation()?.opacity == 0 {
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
            self.backgroundColor = .clear
        }, completion: { finished in
            self.gradientMaskView.layer.removeAllAnimations()
            self.isAnimationInProgress = false
            completion?()
        })
    }
}

fileprivate class OverlayLoadingViewMaskView: UIView {
    
    override class var layerClass: AnyClass { CAShapeLayer.self }
    
    var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    var animationDuration: TimeInterval = 1
    
    var cornerRadius: CGFloat = 10
    var cornerCurve: CALayerCornerCurve = .continuous
    var lineWidth: CGFloat = 1
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = self.cornerRadius == 0 ? 4 : self.cornerRadius
        shapeLayer.path = path(
            frame: CGRect(
                x: lineWidth,
                y: lineWidth,
                width: bounds.width - lineWidth * 2,
                height: bounds.height - lineWidth * 2
            ),
            cornerRadius: cornerRadius
        ).cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        shapeLayer.lineJoin = .round
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.opacity = 1
    }
    
    func animate(with duration: TimeInterval) {
        animationDuration = duration
        
        let inAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration / 4 * 3
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            return animation
        }()
         
        let outAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeStart")
            animation.beginTime = duration / 4
            animation.duration = duration / 4 * 3
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name:  .easeInEaseOut)
            return animation
        }()
        
        let opacityInAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = duration / 3
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name:  .easeInEaseOut)
            return animation
        }()
        
        let opacityOutAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.beginTime = duration / 5 * 4
            animation.duration = duration / 5
            animation.fromValue = 1
            animation.toValue = 0
            animation.timingFunction = CAMediaTimingFunction(name:  .easeInEaseOut)
            return animation
        }()
    
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = duration
        strokeAnimationGroup.repeatCount = .infinity
        strokeAnimationGroup.animations = [
            inAnimation,
            outAnimation,
            opacityInAnimation,
            opacityOutAnimation
        ]
        
        layer.add(strokeAnimationGroup, forKey: "strokeAnimationGroup")
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

        return path
    }
}
