//
//  ApplicationWindowScene.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class ApplicationWindowScene: UIWindowScene {

    @available(*, unavailable, message: "Use `sceneDelegate` instead.")
    override var delegate: UISceneDelegate? {
        set {
            super.delegate = newValue
        }
        get {
            super.delegate
        }
    }
    
    var sceneDelegate: ApplicationWindowSceneDelegate { super.delegate as! ApplicationWindowSceneDelegate }
    
    var window: ApplicationWindow {
        guard let window = sceneDelegate.window
        else {
            fatalError("Application doesn't initialized yet.")
        }
        
        return window
    }
    
    var windowViewController: ApplicationWindowViewController { window.windowRootViewController }
    
    override func open(_ url: URL, options: UIScene.OpenExternalURLOptions?, completionHandler completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
}
