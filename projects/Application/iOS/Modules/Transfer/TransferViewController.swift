//
//  TransferViewController.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import UIKit
import HuetonUI
import SystemUI

class TransferViewController: SUINavigationController {
    
    typealias InitialConfiguration = TransferDetailsViewController.InitialConfiguration
    
    init(initialConfiguration: InitialConfiguration) {
        let detailsViewController = TransferDetailsViewController(initialConfiguration: initialConfiguration)
        super.init(rootViewController: detailsViewController)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        navigationBar.standardAppearance = .hue_standardAppearance
        navigationBar.scrollEdgeAppearance = .hue_scrollEdgeAppearance
        navigationBar.tintColor = .hui_textPrimary
    }
    
    override func trickyAnimatedTransitioning(
        for operation: UINavigationController.Operation
    ) -> SUINavigationControllerAnimatedTransitioning? {
        .transferNavigationTransitioning(with: operation)
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
    
    static func transferNavigationTransitioning(
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
                case .pop:
                    containerView.insertSubview(toView, belowSubview: fromView)
                case .none:
                    break
                @unknown default:
                    break
                }
                
                toView.transform = .identity.scaledBy(x: 0.96, y: 0.96)
                toView.alpha = 0.0
                
                let animations = {
                    toView.transform = .identity
                    toView.alpha = 1
                    
                    fromView.transform = .identity.scaledBy(x: 0.96, y: 0.96)
                    fromView.alpha = 0.0
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
