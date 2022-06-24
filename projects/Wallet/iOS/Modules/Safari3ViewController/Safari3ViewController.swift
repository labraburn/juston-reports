//
//  Safari3ViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import WebKit
import HuetonUI

class Safari3ViewController: UIViewController {
    
    private let browserViewController = Safari3BrowserViewController()
    private let bookmarksViewController = Safari3BookmarksViewController()
    
    private weak var navigationView: AccountStackBrowserNavigationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(
            browserViewController,
            animated: false
        )
    }
    
    func attach(_ view: AccountStackBrowserNavigationView) {
        navigationView = view
        navigationView?.delegate = self
    }
    
    private func show(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        let previousViewController = children.first
        guard viewController != previousViewController
        else {
            return
        }
        
        previousViewController?.willMove(toParent: nil)
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.pinned(edges: view)
        viewController.view.alpha = 0
        
        let animations = {
            previousViewController?.view.alpha = 0
            viewController.view.alpha = 1
        }
        
        let completion = { (finished: Bool) in
            viewController.didMove(toParent: self)
            previousViewController?.view.removeFromSuperview()
            previousViewController?.removeFromParent()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
}

extension Safari3ViewController: AccountStackBrowserNavigationViewDelegate {
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didStartEditing textField: UITextField
    ) {
        show(
            bookmarksViewController,
            animated: true
        )
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didEndEditing textField: UITextField
    ) {
        show(
            browserViewController,
            animated: true
        )
    }
}
