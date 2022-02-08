//
//  SceneDelegate.swift
//  HeaderPageViewController
//
//  Created by Anton Spivak on 10.12.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene)
        else {
            return
        }

        let rootViewController = ExploreViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)

        window = UIWindow(windowScene: scene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
