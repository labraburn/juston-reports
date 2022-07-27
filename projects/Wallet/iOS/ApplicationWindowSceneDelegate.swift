//
//  SceneDelegate.swift
//  Application
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import SwiftyTON

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
        inAppAnnouncementWindow.isHidden = false
    }
    
    // Universal Links and etc.
    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let url = userActivity.webpageURL
            else {
                break
            }
            openURLIfAvailable(url)
        default:
            break
        }
    }
    
    // URL schemes
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let URLContext = URLContexts.first
        else {
            return
        }
        
        openURLIfAvailable(URLContext.url)
    }
    
    @discardableResult
    func openURLIfAvailable(
        _ url: URL
    ) -> Bool {
        guard let schemeURL = SchemeURL(url)
        else {
            return false
        }
        
        switch schemeURL {
        case let .transfer(scheme, configuration):
            showTransferViewControllerIfAvailable(
                with: configuration,
                isEditable: scheme.isEditableParameters
            )
        }
        
        return true
    }
    
    private func showTransferViewControllerIfAvailable(
        with configuration: TransferConfiguration?,
        isEditable: Bool
    ) {
        guard let exploreViewController = window?.windowRootViewController.child as? ExploreViewController
        else {
            return
        }
        
        exploreViewController.showTransferViewControllerIfAvailable(
            with: configuration,
            isEditable: isEditable
        )
    }
}

