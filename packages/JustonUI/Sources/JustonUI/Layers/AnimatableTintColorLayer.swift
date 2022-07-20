//
//  Created by Anton Spivak.
//

import UIKit

public protocol AnimatableTintColorLayerAnimationDelegate: AnyObject {
    
    func signboardImageViewLayer(
        _ layer: AnimatableTintColorLayer,
        didUpdateTintColorWhileAnimation tintColor: CGColor
    )
}

public final class AnimatableTintColorLayer: CALayer {
    
    @NSManaged var tintColor: CGColor
    
    public weak var animationDelegate: AnimatableTintColorLayerAnimationDelegate?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(layer: Any) {
        guard let layer = layer as? AnimatableTintColorLayer
        else {
            fatalError("Can't initialize SignboardImageViewLayer with \(layer)")
        }
        
        super.init(layer: layer)
        
        tintColor = layer.tintColor
    }
    
    public override func display() {
        super.display()
        display(from: presentation() ?? self)
    }
    
    private func display(from layer: AnimatableTintColorLayer) {
        let disableActions = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        
        animationDelegate?.signboardImageViewLayer(
            self,
            didUpdateTintColorWhileAnimation: layer.tintColor
        )
        
        CATransaction.setDisableActions(disableActions)
    }
    
    internal class func isAnimationKeyImplemented(_ key: String) -> Bool {
        key == #keyPath(tintColor)
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
        let system = action(forKey: #keyPath(backgroundColor))
        let sel = NSSelectorFromString("pendingAnimation")
        
        if let expanded = system as? CABasicAnimation {
            animation(expanded)
        } else if let expanded = system as? NSObject, expanded.responds(to: sel) {
            let value = expanded.value(forKeyPath: "_pendingAnimation")
            animation(value as? CABasicAnimation)
        }
        
        return system
    }
}
