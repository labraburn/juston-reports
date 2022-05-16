//
//  Created by Anton Spivak.
//

import UIKit

public class KeyboardLayoutConstraint: NSLayoutConstraint {
    
    public struct WeakView {
        
        public weak var view: UIView?
        
        public init(_ view: UIView) {
            self.view = view
        }
    }
    
    public enum BottomAnchor {
        
        case none
        case screen
        case view(view: WeakView)
    }
    
    private var originalConstant: CGFloat = 0
    private var keyboardHeight: CGFloat = 0
    
    public var bottomAnchor: BottomAnchor = .none {
        didSet {
            guard propagateConstantIfNeeded()
            else {
                return
            }
            
            animateChanges(
                duration: 0.42,
                options: [.curveEaseInOut]
            )
        }
    }
    
    public override var constant: CGFloat {
        get { super.constant }
        set {
            originalConstant = newValue
            propagateConstantIfNeeded()
        }
    }
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrameNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification(_:)),
            name: UIWindow.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @discardableResult
    private func propagateConstantIfNeeded() -> Bool {
        let spacing = CGFloat(16)
        let constant: CGFloat
        if keyboardHeight > 0 {
            switch bottomAnchor {
            case .none:
                constant = originalConstant
            case .screen:
                constant = keyboardHeight + spacing
            case let .view(wview):
                if let view = wview.view,
                   let superview = view.superview,
                   let window = view.window
                { 
                    let frame = superview.convert(view.frame, to: nil)
                    let target = keyboardHeight - (window.bounds.height - frame.minY) + spacing
                    constant = target > 0 ? target : originalConstant
                }
                else {
                    constant = keyboardHeight + spacing
                }
            }
        } else {
            constant = originalConstant
        }
        
        guard super.constant != constant
        else {
            return false
        }
        
        super.constant = constant
        return true
    }
    
    private func animateChanges(
        notification: Notification
    ) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: Double(0.24))
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber ?? NSNumber(value: UInt(0))
        
        animateChanges(
            duration: TimeInterval(duration.doubleValue > 0 ? duration.doubleValue : 0.24) * 1.5,
            options: UIView.AnimationOptions(rawValue: curve.uintValue)
        )
    }
    
    private func animateChanges(
        duration: TimeInterval,
        options: UIView.AnimationOptions
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: options,
            animations: {
                (self.firstItem as? UIView)?.superview?.layoutIfNeeded()
                (self.secondItem as? UIView)?.superview?.layoutIfNeeded()
            }, completion: { finished in }
        )
    }
    
    // MARK: Observing
    
    @objc
    private func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let frame = frameValue.cgRectValue
        keyboardHeight = frame.size.height
        
        guard propagateConstantIfNeeded()
        else {
            return
        }
        
        animateChanges(notification: notification)
    }
    
    @objc
    private func keyboardDidChangeFrameNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let frame = frameValue.cgRectValue
        keyboardHeight = frame.size.height
        
        guard propagateConstantIfNeeded()
        else {
            return
        }
        
        animateChanges(notification: notification)
    }
    
    @objc
    private func keyboardWillHideNotification(_ notification: Notification) {
        keyboardHeight = 0
        propagateConstantIfNeeded()
        animateChanges(notification: notification)
    }
}
