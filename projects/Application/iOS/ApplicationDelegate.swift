//
//  ApplicationDelegate.swift
//  Application
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let sceneConfiguration: UISceneConfiguration
        switch connectingSceneSession.role {
        case .windowApplication:
            sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
            sceneConfiguration.delegateClass = ApplicationWindowSceneDelegate.self
            sceneConfiguration.sceneClass = ApplicationWindowScene.self
        case .windowExternalDisplay:
            fatalError("Don't support external display.")
        default:
            fatalError("Scene role is unknown.")
        }
        
        return sceneConfiguration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    
    }
}

