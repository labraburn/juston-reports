//
//  AccountAddingNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit

class AccountAddingNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bui_backgroundPrimary
        
        let titleTextAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.font(for: .title2),
            .foregroundColor : UIColor.bui_textPrimary
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
        navigationBar.tintColor = .bui_textPrimary
        
        navigationBar.prefersLargeTitles = false
        navigationBar.layer.masksToBounds = true
    }
}

extension AccountAddingNavigationController: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        AccountAddingNavigationAnimatedTransitioning(navigationOperation: operation)
    }
}

private class AccountAddingNavigationAnimatedTransitioning: NSObject {
    
    private let navigationOperation: UINavigationController.Operation
    private var animator: UIViewPropertyAnimator?
    
    init(navigationOperation: UINavigationController.Operation) {
        self.navigationOperation = navigationOperation
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountAddingNavigationAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
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
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            timingParameters: UISpringTimingParameters(damping: 0.76, response: 0.4)
        )
        
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to)
        else {
            fatalError("This is case not possible.")
        }
        
        let containerView = transitionContext.containerView
        let navigationOperation = navigationOperation
        
        toView.frame = containerView.bounds
        
        switch navigationOperation {
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
        
        animator.addAnimations({
            toView.transform = .identity
            toView.alpha = 1
            
            switch navigationOperation {
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
        })
        
        animator.addCompletion({ position in
            toView.transform = .identity
            fromView.transform = .identity
            
            transitionContext.completeTransition(position == .end)
            if transitionContext.transitionWasCancelled {
                toView.removeFromSuperview()
            }
        })
        
        self.animator = animator
        return animator
    }
}
