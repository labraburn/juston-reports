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
    
    // Private
    
    @discardableResult
    private func openURLIfAvailable(
        _ url: URL
    ) -> Bool {
        guard let deeplinkURL = DeeplinkURL(url)
        else {
            return false
        }
        
        switch deeplinkURL {
        case let .tonURL(convenienceURL):
            switch convenienceURL {
            case let .transfer( destination, amount, text):
                openTransferViewController(destination: destination, amount: amount, message: text)
            }
        case .address(_):
            break
        case let .transfer(destination, amount, text):
            openTransferViewController(destination: destination, amount: amount, message: text)
        }
        
        return true
    }
    
    private func openTransferViewController(
        destination: Address,
        amount: Currency?,
        message: String?
    ) {
        guard let exploreViewController = window?.windowRootViewController.child as? ExploreViewController
        else {
            return
        }
        
        exploreViewController.showTransferViewControllerIfAvailable(
            destination: destination,
            amount: amount,
            message: message
        )
    }
}

