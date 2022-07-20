//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

internal class FloatingTabBarAnimatedTransitioning: NSObject {
    
    private let animationDuration = 0.32
    private var animator: UIViewPropertyAnimator?

    var animations: [() -> Void] = []
    var completions: [(UIViewAnimatingPosition) -> Void] = []

    func addAnimations(_ animation: @escaping () -> Void) {
        animations.append(animation)
    }

    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        completions.append(completion)
    }
}

extension FloatingTabBarAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        (transitionContext?.isAnimated == true) ? animationDuration : 0
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        animator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        animator(using: transitionContext)
    }

    private func animator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // Return existed if available
        if let animator = self.animator {
            return animator
        }
        
        guard let from = transitionContext.viewController(forKey: .from),
              let to = transitionContext.viewController(forKey: .to)
        else {
            let error = """
            FloatingTabBarAnimatedTransitioning:
            Couldn't locate viewController `from` or `to` in \(transitionContext)
            """
            fatalError(error)
        }

        let containerView = transitionContext.containerView
        let bounds = containerView.bounds

        to.view.frame = bounds
        containerView.addSubview(to.view)

        UIView.performWithoutAnimation {
            to.view.setNeedsLayout()
            to.view.layoutIfNeeded()
        }
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            timingParameters: UISpringTimingParameters(damping: 0.76, response: 0.24)
        )
        
        to.view.alpha = 0
        to.view.transform = .identity.scaledBy(x: 0.96, y: 0.96)
        
        animator.addAnimations({
            from.view.transform = .identity.scaledBy(x: 0.96, y: 0.96)
            from.view.alpha = 0.0
        })
        
        animator.addAnimations({
            to.view.alpha = 1
            to.view.transform = .identity
        }, delayFactor: 0.3)
        
        animator.addCompletion({ _ in
            if transitionContext.transitionWasCancelled {
                to.view.removeFromSuperview()
                transitionContext.completeTransition(false)
            } else {
                from.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            
            to.view.transform = .identity
            from.view.transform = .identity
        })

        animations.forEach {
            animator.addAnimations($0)
        }

        completions.forEach {
            animator.addCompletion($0)
        }

        self.animator = animator
        return animator
    }
}
