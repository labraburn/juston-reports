//
//  SceneDelegate.swift
//  Application
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class ApplicationWindowSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: ApplicationWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? ApplicationWindowScene
        else {
            return
        }
        
        let viewController = LaunchViewController()
        viewController.delegate = self
        
        let window = ApplicationWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        window.windowRootViewController.exchange(
            viewController,
            at: .application,
            animated: false
        )
        
        self.window = window
    }
    
    enum ViewControllerType {
        
        case loading
        case dashboard
    }
    
    private func setApplicationController(with type: ViewControllerType, animated: Bool = true) {
        window?.windowRootViewController.exchange(
            type.viewController(with: self),
            at: .application,
            animated: animated
        )
    }
}

extension ApplicationWindowSceneDelegate: LaunchViewControllerDelegate {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool) {
        setApplicationController(with: .dashboard)
    }
}

extension ApplicationWindowSceneDelegate.ViewControllerType {
    
    func viewController(with sceneDelegate: ApplicationWindowSceneDelegate) -> UIViewController {
        switch self {
        case .loading:
            let viewController = LaunchViewController()
            viewController.delegate = sceneDelegate
            return viewController
        case .dashboard:
            let viewController = DashboardViewController()
            return viewController
        }
    }
}

