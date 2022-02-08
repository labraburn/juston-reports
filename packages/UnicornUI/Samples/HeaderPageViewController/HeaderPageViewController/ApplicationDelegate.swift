//
//  ApplicationDelegate.swift
//  HeaderPageViewController
//
//  Created by Anton Spivak on 10.12.2021.
//

import UIKit

@main
class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
