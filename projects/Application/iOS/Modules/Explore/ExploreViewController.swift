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
        
        let dashboardNavigationController = NavigationController(rootViewController: DashboardViewController())
        dashboardNavigationController.tabBarItem = {
            let item = FloatingTabBarItem()
            item.image = .hui_tabBarCards44
            item.selectedTintColor = .hui_letter_blue
            item.deselectedTintColor = .hui_tabBarDeselected
            return item
        }()
        
        let settingsNavigationController = C42NavigationController(rootViewController: SettingsViewController())
        settingsNavigationController.tabBarItem = {
            let item = FloatingTabBarItem()
            item.image = .hui_tabBarGear44
            item.selectedTintColor = .hui_letter_violet
            item.deselectedTintColor = .hui_tabBarDeselected
            return item
        }()
        
        viewControllers = [
            dashboardNavigationController,
            settingsNavigationController
        ]
        
        selectedIndex = 0
    }
}
