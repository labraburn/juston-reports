//
//  AlertViewControllerTransitioningDelegate.swift
//  iOS
//
//  Created by Anton Spivak on 31.03.2022.
//

import UIKit

class AlertViewControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        presenting.view.tintAdjustmentMode = .dimmed
        return AlertViewControllerAnimatedTransitioning(operation: .presenting, presentingViewController: presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        AlertViewControllerAnimatedTransitioning(operation: .dismissing, presentingViewController: nil)
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        AlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

private class AlertPresentationController: UIPresentationController {
    
    private let visualEffectView = UIVisualEffectView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.effect = nil
    })
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView
        else {
            return
        }
        
        containerView.addSubview(visualEffectView)
        visualEffectView.pinned(edges: containerView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.visualEffectView.effect = UIBlurEffect(style: .systemChromeMaterial)
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.visualEffectView.effect = nil
            if !context.isCancelled {
                self.visualEffectView.removeFromSuperview()
            }
        })
    }
}

private class AlertViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Operation {
        
        case presenting
        case dismissing
    }
    
    private var animator: UIViewPropertyAnimator?
    private var operation: Operation
    private weak var presentingViewController: UIViewController?
    
    init(operation: Operation, presentingViewController: UIViewController?) {
        self.operation = operation
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.32
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = animator {
            return animator
        }
        
        let timingParameters: UITimingCurveProvider
        switch operation {
        case .presenting:
            timingParameters = UISpringTimingParameters(damping: 0.79, response: 0.4)
        case .dismissing:
            timingParameters = UISpringTimingParameters(damping: 1, response: 0.3)
        }
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            timingParameters: timingParameters
        )
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let containerView = transitionContext.containerView
        let operation = operation
        let bounds = containerView.bounds
        let safeAreaInsets = containerView.safeAreaInsets
        
        if let toView = toView {
            containerView.addSubview(toView)
        }
        
        let presentingViewController = presentingViewController ?? transitionContext.viewController(forKey: .from)?.presentingViewController
        
        switch operation {
        case .presenting:
            let width = containerView.bounds.width - 48
            let systemLayoutSizeFitting = toView?.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            ) ?? .zero
            
            let size = CGSize(
                width: width,
                height: max(min(systemLayoutSizeFitting.height, bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 128), 64)
            )
            
            toView?.bounds = CGRect(origin: .zero, size: size)
            toView?.center = CGPoint(x: bounds.midX, y: bounds.midY)
            toView?.transform = .identity.translatedBy(x: 0, y: bounds.height).scaledBy(x: 0.8, y: 0.8)
            toView?.alpha = 0.2
        case .dismissing:
            break
        }
        
        animator.addAnimations({
            switch operation {
            case .presenting:
                presentingViewController?.view.tintAdjustmentMode = .dimmed
                toView?.transform = .identity
                toView?.alpha = 1
            case .dismissing:
                presentingViewController?.view.tintAdjustmentMode = .automatic
                fromView?.transform = .identity.translatedBy(x: 0, y: bounds.height).scaledBy(x: 0.8, y: 0.8)
                fromView?.alpha = 0
            }
        })
        
        animator.addCompletion({ position in
            toView?.transform = .identity
            fromView?.transform = .identity
            
            transitionContext.completeTransition(position == .end)
            if !transitionContext.transitionWasCancelled && operation == .dismissing {
                toView?.removeFromSuperview()
            }
        })
        
        self.animator = animator
        return animator
    }
}
