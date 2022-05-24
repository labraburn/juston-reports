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
        
        let viewController = ExploreViewController()
        
        let window = ApplicationWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        window.windowRootViewController.child = viewController
        
        self.window = window
        
        let inAppAnnouncementWindow = InAppAnnouncementWindow(windowScene: windowScene)
        inAppAnnouncementWindow.makeKeyAndVisible()
    }
}

