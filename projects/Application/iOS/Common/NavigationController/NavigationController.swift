//
//  NavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 24.05.2022.
//

import UIKit

import UIKit
import HuetonUI
import SystemUI

class NavigationController: SUINavigationController {
    
    /// Experimental feature
    var isPageSheetFittedIntoContentSize: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        transitioningDelegate = self
        modalPresentationStyle = .custom
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
        
        navigationBar.prefersLargeTitles = false
        navigationBar.layer.masksToBounds = true
    }
    
    override func trickyAnimatedTransitioning(
        for operation: UINavigationController.Operation
    ) -> SUINavigationControllerAnimatedTransitioning? {
        .defaultNavigationTransitioning(with: operation)
    }
}

extension NavigationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = SheetPresentationController.withPresentedViewController(
            presented,
            presenting: presenting
        )
        presentationController.detents = [
            .init(
                identifier: .detentIdentifierLarge,
                resolutionBlock: { [weak self] containerView, maximumRect in
                    guard let self = self,
                          self.isPageSheetFittedIntoContentSize,
                          let viewControllerView = self.topViewController?.view // force load view
                    else {
                        return maximumRect.height
                    }
                    
                    self.view?.layoutIfNeeded()
                    viewControllerView.layoutIfNeeded()
                    
                    var height = viewControllerView.systemLayoutSizeFitting(
                        CGSize(
                            width: maximumRect.size.width,
                            height: UIView.layoutFittingExpandedSize.height
                        ),
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .defaultLow
                    ).height
                    
                    if viewControllerView.safeAreaInsets == .zero {
                        let safeAreaInsets = containerView.safeAreaInsets
                        height += safeAreaInsets.bottom
                        height += 56 // TODO: Fixme
                    }
                    
                    return min(maximumRect.size.height, height)
                }
            )
        ]
        return presentationController
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
    
    static func defaultNavigationTransitioning(
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
