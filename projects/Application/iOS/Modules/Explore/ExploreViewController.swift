//
//  ExploreViewController.swift
//  iOS
//
//  Created by Anton Spivak on 19.04.2022.
//

import UIKit
import HuetonUI

class ExploreViewController: FloatingTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bookmarksViewController = BookmarksViewController()
        bookmarksViewController.tabBarItem = {
            let item = UITabBarItem()
            item.image = .hui_tabBarPlanet44
            return item
        }()
        
        let dashboardViewController = DashboardViewController()
        dashboardViewController.tabBarItem = {
            let item = UITabBarItem()
            item.image = .hui_tabBarCards44
            return item
        }()
        
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = {
            let item = UITabBarItem()
            item.image = .hui_tabBarGear44
            return item
        }()
        
        viewControllers = [
            instantiateNavigationController(rootViewController: bookmarksViewController),
            instantiateNavigationController(rootViewController: dashboardViewController),
            instantiateNavigationController(rootViewController: settingsViewController)
        ]
        
        selectedIndex = 1
    }
    
    private func instantiateNavigationController(
        rootViewController: UIViewController
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        let navigationItemAppearence = UINavigationBarAppearance()
        navigationItemAppearence.configureWithDefaultBackground()
        
        let navigationBar = navigationController.navigationBar
        navigationBar.standardAppearance = navigationItemAppearence
        navigationBar.scrollEdgeAppearance = navigationItemAppearence
        
        return navigationController
    }
}
