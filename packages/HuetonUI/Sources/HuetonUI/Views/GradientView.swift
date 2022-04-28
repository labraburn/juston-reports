//
//  Created by Anton Spivak.
//  

import UIKit

private class _GradientLayer: CAGradientLayer {
    
    override class func needsDisplay(forKey key: String) -> Bool {
        false
    }
    
    override func action(forKey event: String) -> CAAction? {
        NSNull()
    }
}

public class GradientLayer: CALayer {
    
    @NSManaged public var angle: Double
    @NSManaged public var colors: [CGColor]
    @NSManaged public var locations: [Double]
    
    let systemLayer: CAGradientLayer = _GradientLayer()
    
    public override init() {
        super.init()
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    public override init(layer: Any) {
        guard let layer = layer as? GradientLayer
        else {
            fatalError("Can't initialize GradientLayer with \(layer)")
        }
        
        super.init(layer: layer)
        
        angle = layer.angle
        colors = layer.colors
        locations = layer.locations
    }
    
    private func initialize() {
        addSublayer(systemLayer)
    }
    
    public override func display() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        super.display()
        display(from: presentation() ?? self)
        
        CATransaction.commit()
    }
    
    private func display(from layer: GradientLayer) {
        systemLayer.frame = layer.bounds
        
        systemLayer.colors = layer.colors
        systemLayer.locations = layer.locations.map({ NSNumber(floatLiteral: $0) })
        
        let points = layer._points()
        systemLayer.startPoint = points.0
        systemLayer.endPoint = points.1
        
        systemLayer.setNeedsDisplay()
        systemLayer.displayIfNeeded()
    }
    
    private func _angle() -> Double {
        var angle = abs(angle).truncatingRemainder(dividingBy: 360)
        angle = angle + 45
        return angle
    }
    
    private func _points() -> (CGPoint, CGPoint) {
        let x = _angle() / 360
        let a = pow(sin((2 * .pi * ((x + 0.75) / 2))), 2)
        let b = pow(sin((2 * .pi * ((x + 0.0) / 2))), 2);
        let c = pow(sin((2 * .pi * ((x + 0.25) / 2))), 2);
        let d = pow(sin((2 * .pi * ((x + 0.5) / 2))), 2);
        return (CGPoint(x: a, y: b), CGPoint(x: c, y: d))
    }
    
    internal class func isAnimationKeyImplemented(_ key: String) -> Bool {
        key == #keyPath(angle) || key == #keyPath(colors) || key == #keyPath(locations)
    }
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        guard isAnimationKeyImplemented(key)
        else {
            return super.needsDisplay(forKey: key)
        }
        
        return true
    }
    
    public override func action(forKey event: String) -> CAAction? {
        guard Self.isAnimationKeyImplemented(event)
        else {
            return super.action(forKey: event)
        }
        
        let action = _action({ animation in
            animation?.keyPath = event
            animation?.fromValue = presentation()?.value(forKeyPath: event) ?? value(forKeyPath: event)
            animation?.toValue = nil
        })
        
        return action
    }
    
    private func _action(_ animation: ((_ animation: CABasicAnimation?) -> ())) -> CAAction? {
        if CATransaction.disableActions() {
            return nil
        }
        
        var system = action(forKey: #keyPath(backgroundColor))
        let sel = NSSelectorFromString("pendingAnimation")
        
        if let expanded = system as? CABasicAnimation {
            animation(expanded)
        } else if let expanded = system as? NSObject, expanded.responds(to: sel) {
            let value = expanded.value(forKeyPath: "_pendingAnimation")
            animation(value as? CABasicAnimation)
        } else if system == nil {
            let value = CABasicAnimation(keyPath: "")
            value.duration = UIView.inheritedAnimationDuration
            animation(value)
            system = value
        }
        
        return system
    }
}

open class GradientView: UIView {
    
    public override class var layerClass: AnyClass { GradientLayer.self }
    private var _layer: GradientLayer { layer as! GradientLayer }
    
    /// Gradient colors
    @objc public var colors: [UIColor] {
        set { _layer.colors = newValue.map({ $0.cgColor }) }
        get { _layer.colors.map({ UIColor(cgColor: $0) }) }
    }
    
    /// Value in º
    @objc public var angle: Double {
        set { _layer.angle = newValue }
        get { _layer.angle }
    }
    
    ///
    @objc public var locations: [Double] {
        set { _layer.locations = newValue }
        get { _layer.locations }
    }
    
    public init(colors: [UIColor], angle: CGFloat) {
        super.init(frame: .zero)
        clipsToBounds = true
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.colors = colors
        self.locations = [0, 1]
        self.angle = angle
        
        CATransaction.commit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        colors = [.cyan, .magenta]
        locations = [0, 1]
        angle = 45
        
        CATransaction.commit()
    }
}
