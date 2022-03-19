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
        
        let viewController = LaunchViewController()
        viewController.delegate = self
        
        let window = ApplicationWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        window.windowRootViewController.exchange(
//            UINavigationController(rootViewController: DebugViewController()),
            viewController,
            at: .application,
            animated: false
        )
        
        self.window = window
    }
    
    enum ViewControllerType {
        
        case loading
        case onboarding
        case dashboard(address: Address.RawAddress)
    }
    
    private func setApplicationController(with type: ViewControllerType, animated: Bool = true) {
        window?.windowRootViewController.exchange(
            type.viewController(with: self),
            at: .application,
            animated: animated
        )
    }
}

extension ApplicationWindowSceneDelegate: OnboardingViewControllerDelegate {
    
    func onboardingViewControllerDidComplete(_ viewController: OnboardingViewController) {
        Task {
            do {
                let storage = SecureStorage()
                guard let key = (try await storage.keys()).first
                else {
                    fatalError("Address not found.")
                }
                
                self.setApplicationController(with: .dashboard(address: key.rawAddress), animated: false)
            } catch {
                viewController.presentAlertViewController(
                    with: error,
                    title: "Can't retreive saved addresses."
                )
            }
        }
    }
}

extension ApplicationWindowSceneDelegate: LaunchViewControllerDelegate {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool) {
        Task {
            do {
                let storage = SecureStorage()
                if let key = (try await storage.keys()).first {
                    self.setApplicationController(with: .dashboard(address: key.rawAddress), animated: false)
                } else {
                    self.setApplicationController(with: .onboarding, animated: false)
                }
            } catch {
                viewController.presentAlertViewController(
                    with: error,
                    title: "Can't retreive saved addresses."
                )
            }
        }
    }
}

extension ApplicationWindowSceneDelegate.ViewControllerType {
    
    func viewController(with sceneDelegate: ApplicationWindowSceneDelegate) -> UIViewController {
        switch self {
        case .loading:
            let viewController = LaunchViewController()
            viewController.delegate = sceneDelegate
            return viewController
        case let .dashboard(rawAddress):
            let viewController = DashboardViewController()
            return viewController
        case .onboarding:
            let viewController = OnboardingViewController()
            viewController.delegate = sceneDelegate
            return viewController
        }
    }
}

