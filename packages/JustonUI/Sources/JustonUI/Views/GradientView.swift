//
//  Created by Anton Spivak.
//  

import UIKit

private class GradientLayer: CAGradientLayer {
    
    @NSManaged public var _angle: Double
    @NSManaged public var _colors: [CGColor]
    @NSManaged public var _locations: [Double]
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(layer: Any) {
        guard let layer = layer as? GradientLayer
        else {
            fatalError("Can't initialize GradientLayer with \(layer)")
        }
        
        super.init(layer: layer)
        
        _angle = layer._angle
        _colors = layer._colors
        _locations = layer._locations
    }
    
    public override func display() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        super.display()
        display(from: presentation() ?? self)
        
        CATransaction.commit()
    }
    
    private func display(from layer: GradientLayer) {
        colors = layer._colors
        locations = layer._locations.map({ NSNumber(floatLiteral: $0) })
        
        let points = layer._points()
        startPoint = points.0
        endPoint = points.1
    }
    
    private func __angle() -> Double {
        var angle = abs(_angle).truncatingRemainder(dividingBy: 360)
        angle = angle + 45
        return angle
    }
    
    private func _points() -> (CGPoint, CGPoint) {
        let x = __angle() / 360
        let a = pow(sin((2 * .pi * ((x + 0.75) / 2))), 2)
        let b = pow(sin((2 * .pi * ((x + 0.0) / 2))), 2);
        let c = pow(sin((2 * .pi * ((x + 0.25) / 2))), 2);
        let d = pow(sin((2 * .pi * ((x + 0.5) / 2))), 2);
        return (CGPoint(x: a, y: b), CGPoint(x: c, y: d))
    }
    
    internal class func isAnimationKeyImplemented(_ key: String) -> Bool {
        key == #keyPath(_angle) || key == #keyPath(_colors) || key == #keyPath(_locations)
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
        set { _layer._colors = newValue.map({ $0.cgColor }) }
        get { _layer._colors.map({ UIColor(cgColor: $0) }) }
    }
    
    /// Value in º
    @objc public var angle: Double {
        set { _layer._angle = newValue }
        get { _layer._angle }
    }
    
    ///
    @objc public var locations: [Double] {
        set { _layer._locations = newValue }
        get { _layer._locations }
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
