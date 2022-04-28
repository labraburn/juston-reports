//
//  Created by Anton Spivak
//

import UIKit

open class FloatingTabBarController: UITabBarController {
    
    private var transitionAnimatedTransitioning: FloatingTabBarAnimatedTransitioning?
    
    public var floatingTabBar: FloatingTabBar {
        super.tabBar as! FloatingTabBar
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let tabBar = FloatingTabBar()
        let tabBarApearance = UITabBarAppearance()
        tabBarApearance.configureWithTransparentBackground()

        tabBar.standardAppearance = tabBarApearance
        if #available(iOS 15, *) {
            tabBar.scrollEdgeAppearance = tabBarApearance
        }
        
        delegate = self
        setValue(tabBar, forKey: "tabBar")
    }
}

extension FloatingTabBarController: UITabBarControllerDelegate {
    
    open func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let fromIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
              let toIndex = tabBarController.viewControllers?.firstIndex(of: toVC)
        else {
            return nil
        }

        if transitionAnimatedTransitioning == nil && UIAccessibility.isReduceMotionEnabled {
            // Return nil for not interactive transitions
            return nil
        }

        if transitionAnimatedTransitioning == nil {
            transitionAnimatedTransitioning = FloatingTabBarAnimatedTransitioning()
        }

        // Start on next runloop cyecle with system stransition
        DispatchQueue.main.async {
            self.transitionCoordinator?.animate(
                alongsideTransition: { _ in },
                completion: { [weak self] context in
                    if context.isCancelled {
                        fromVC.setNeedsStatusBarAppearanceUpdate()
                        self?.selectedIndex = fromIndex
                    }
                    else {
                        toVC.setNeedsStatusBarAppearanceUpdate()
                        self?.selectedIndex = toIndex
                    }
                }
            )
        }

        transitionAnimatedTransitioning?.addCompletion { [weak self] _ in
            self?.transitionAnimatedTransitioning = nil
        }

        return transitionAnimatedTransitioning
    }

    open func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        transitionCoordinator == nil && selectedViewController != viewController
    }
}

extension UIViewController {
    
    public var floatingTabBarController: FloatingTabBarController? {
        tabBarController as? FloatingTabBarController
    }
}
