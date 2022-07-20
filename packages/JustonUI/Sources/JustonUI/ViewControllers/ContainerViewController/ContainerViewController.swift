//
//  ContainerViewController.swift
//  
//
//  Created by Anton Spivak on 19.04.2022.
//

import UIKit

open class ContainerViewController: UIViewController {

    open override var childForStatusBarStyle: UIViewController? { child }
    open override var childForHomeIndicatorAutoHidden: UIViewController? { child }
    open override var childForStatusBarHidden: UIViewController? { child }
    open override var childViewControllerForPointerLock: UIViewController? { child }
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? { child }

    public var child: UIViewController? {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance(animated: animated)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        children.forEach({
            removeChildViewControllerIfNeeded($0)
        })
        
        addChildViewControllerIfNeeded(child)
        child?.viewIfLoaded?.frame = view.bounds
    }
    
    // MARK: Private
    
    private func addChildViewControllerIfNeeded(_ viewController: UIViewController?) {
        guard let viewController = viewController,
              !children.contains(viewController)
        else {
            return
        }
        
        viewController.loadViewIfNeeded()

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        updateAppearance(animated: true)
    }
    
    private func removeChildViewControllerIfNeeded(_ viewController: UIViewController?) {
        guard let viewController = viewController,
              viewController != child,
              children.contains(viewController)
        else {
            return
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        
        updateAppearance(animated: false)
    }
    
    private func updateAppearance(
        animated: Bool,
        duration: TimeInterval = 0.21
    ) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
}
