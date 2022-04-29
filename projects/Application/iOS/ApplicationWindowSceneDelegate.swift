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
        window.windowRootViewController.child = viewController
        
        self.window = window
        
        let inAppAnnouncementWindow = InAppAnnouncementWindow(windowScene: windowScene)
        inAppAnnouncementWindow.makeKeyAndVisible()
    }
    
    enum ViewControllerType {
        
        case loading
        case explore
    }
    
    private func setApplicationController(with type: ViewControllerType, animated: Bool = true) {
        window?.windowRootViewController.child = type.viewController(with: self)
    }
}

extension ApplicationWindowSceneDelegate: LaunchViewControllerDelegate {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool) {
        setApplicationController(with: .explore, animated: false)
    }
}

extension ApplicationWindowSceneDelegate.ViewControllerType {
    
    func viewController(with sceneDelegate: ApplicationWindowSceneDelegate) -> UIViewController {
        switch self {
        case .loading:
            let viewController = LaunchViewController()
            viewController.delegate = sceneDelegate
            return viewController
        case .explore:
            let viewController = ExploreViewController()
            return viewController
        }
    }
}

