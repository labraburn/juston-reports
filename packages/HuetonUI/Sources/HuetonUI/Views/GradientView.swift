//
//  Created by Anton Spivak.
//  

import UIKit

public class GradientLayer: CALayer {
    
    @NSManaged public var angle: Double
    @NSManaged public var colors: [CGColor]
    @NSManaged public var locations: [Double]
    
    let systemLayer: CAGradientLayer = CAGradientLayer()
    
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
    }
    
    private func initialize() {
        addSublayer(systemLayer)
    }
    
    public override func display() {
        super.display()
        display(from: presentation() ?? self)
    }
    
    private func display(from layer: GradientLayer) {
        let disableActions = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        
        systemLayer.frame = layer.bounds
        
        systemLayer.colors = layer.colors
        systemLayer.locations = layer.locations.map({ NSNumber(floatLiteral: $0) })
        
        let points = layer._points()
        systemLayer.startPoint = points.0
        systemLayer.endPoint = points.1
        
        CATransaction.setDisableActions(disableActions)
    }
    
    private func _angle() -> Double {
        var angle = angle
        
        if angle < 0.0 {
            angle = 360.0 + angle
        }

        angle = angle + 45

        let m = Int(angle / 360)
        if (m > 0) {
            angle = angle - Double(360 * m)
        }
        
        return angle
    }
    
    private func _points() -> (CGPoint, CGPoint) {
        var x: Double = 0.0
        var y: Double = 0.0
      
        let rotate = _angle() / 90
      
        // 1...4 can be understood to denote the four quadrants
        if rotate <= 1 {
            y = rotate
        } else if rotate <= 2 {
            y = 1
            x = rotate - 1
        } else if rotate <= 3 {
            x = 1
            y = 1 - (rotate - 2)
        } else if rotate <= 4 {
            x = 1 - (rotate - 3)
        }
      
        let start = CGPoint(x: 1 - CGFloat(y), y: 0 + CGFloat(x))
        let end = CGPoint(x: 0 + CGFloat(y), y: 1 - CGFloat(x))
      
        return (start, end)
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        clipsToBounds = true
        colors = [.cyan, .magenta]
        locations = [0, 1]
        angle = 45
    }
}
