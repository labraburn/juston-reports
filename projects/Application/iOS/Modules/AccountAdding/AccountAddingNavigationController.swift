//
//  AccountAddingNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import SystemUI

class AccountAddingNavigationController: SUINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        let titleTextAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.font(for: .title2),
            .foregroundColor : UIColor.hui_textPrimary
        ]
        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.shadowColor = .clear
        scrollEdgeAppearance.backgroundColor = .clear
        scrollEdgeAppearance.titleTextAttributes = titleTextAttributes
        scrollEdgeAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        standardAppearance.titleTextAttributes = titleTextAttributes
        standardAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        
        navigationBar.standardAppearance = standardAppearance
        navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        navigationBar.tintColor = .hui_textPrimary
        
        navigationBar.prefersLargeTitles = false
        navigationBar.layer.masksToBounds = true
    }
    
    override func trickyAnimatedTransitioning(
        for operation: UINavigationController.Operation
    ) -> SUINavigationControllerAnimatedTransitioning? {
        .addingNavigationTransitioning(with: operation)
    }
}

private extension UINavigationController.Operation {
    
    var duration: TimeInterval {
        switch self {
        case .push:
            return 0.54
        default:
            return 0.38
        }
    }
}

private extension SUINavigationControllerAnimatedTransitioning {
    
    static func addingNavigationTransitioning(
        with operation: UINavigationController.Operation
    ) -> SUINavigationControllerAnimatedTransitioning {
        SUINavigationControllerAnimatedTransitioning(
            navigationOperation: operation,
            transitionDuration: { transitionContext in
                operation.duration
            },
            navigationBarTransitionDuration: { _ in
                operation.duration / 5 * 3 // speed up
            },
            transitionAnimation: { transitionContext in
                guard let fromView = transitionContext.view(forKey: .from),
                      let toView = transitionContext.view(forKey: .to)
                else {
                    fatalError("This is case not possible.")
                }
                
                let containerView = transitionContext.containerView
                toView.frame = containerView.bounds
                
                switch operation {
                case .push:
                    containerView.addSubview(toView)
                    toView.transform = .identity.translatedBy(x: containerView.bounds.width, y: 0)
                case .pop:
                    containerView.insertSubview(toView, belowSubview: fromView)
                    
                    toView.transform = .identity.scaledBy(x: 0.8, y: 0.8)
                    toView.alpha = 0.2
                case .none:
                    break
                @unknown default:
                    break
                }
                
                let animations = {
                    toView.transform = .identity
                    toView.alpha = 1
                    
                    switch operation {
                    case .push:
                        fromView.transform = .identity.scaledBy(x: 0.8, y: 0.8)
                        fromView.alpha = 0.2
                    case .pop:
                        fromView.transform = .identity.translatedBy(x: containerView.bounds.width, y: 0)
                    case .none:
                        break
                    @unknown default:
                        break
                    }
                }
                
                let completion = { (_ finished: Bool) in
                    let transitionWasCancelled = transitionContext.transitionWasCancelled || !finished
                    
                    toView.alpha = 1
                    toView.transform = .identity
                    
                    fromView.alpha = 1
                    fromView.transform = .identity
                    
                    if transitionWasCancelled {
                        toView.removeFromSuperview()
                    } else {
                        fromView.removeFromSuperview()
                    }
                    
                    transitionContext.completeTransition(!transitionWasCancelled)
                }
                
                if transitionContext.isInteractive {
                    UIView.animate(
                        withDuration: operation.duration,
                        delay: 0,
                        options: [.curveLinear],
                        animations: animations,
                        completion: completion
                    )
                } else {
                    UIView.animate(
                        withDuration: operation.duration,
                        delay: 0,
                        usingSpringWithDamping: 0.76,
                        initialSpringVelocity: 0.4,
                        options: [.curveEaseOut],
                        animations: animations,
                        completion: completion
                    )
                }
            }
        )
    }
}
