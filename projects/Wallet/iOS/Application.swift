//
//  Application.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import JustonUI

class Application: UIApplication {

    override class var shared: Application { super.shared as! Application }
    
    @available(*, unavailable, message: "Use `applictionDelegate` instead")
    override var delegate: UIApplicationDelegate? {
        set {
            super.delegate = newValue
        }
        get {
            super.delegate
        }
    }
    
    var applictionDelegate: ApplicationDelegate { super.delegate as! ApplicationDelegate }
    
    var connectedApplicationWindowScenes: [ApplicationWindowScene] {
        connectedScenes.compactMap({ $0 as? ApplicationWindowScene })
    }
    
    var foregroundActiveApplicationWindowScenes: [ApplicationWindowScene] {
        connectedApplicationWindowScenes.filter({ $0.activationState == .foregroundActive })
    }
    
    var foregroundActiveApplicationWindowScene: ApplicationWindowScene? {
        foregroundActiveApplicationWindowScenes.first
    }
    
    func openURLIfAvailable(
        _ url: URL
    ) -> Bool {
        guard let sceneDelegate = foregroundActiveApplicationWindowScene?.sceneDelegate
        else {
            return false
        }
        
        return sceneDelegate.openURLIfAvailable(url)
    }
    
    /// Handle UITextView URLs
    @objc(_openURL:originatingView:completionHandler:)
    func _openURL(
        _ url: URL,
        originatingView: UIView?,
        completionHandler completion: ((Bool) -> ())?
    ) {
        let window = originatingView?.applicationWindow ?? foregroundActiveApplicationWindowScene?.window
        let host = url.host ?? ""
        
        let inAppable = ["hueton", "juston", "venera"]
        var canOpenInApp = false
        
        inAppable.forEach({
            guard !canOpenInApp
            else {
                return
            }
            
            canOpenInApp = host.contains($0)
        })
        
        guard canOpenInApp
        else {
            open(url, completionHandler: completion)
            return
        }
        
        window?
            .windowRootViewController
            .topmostPresentedViewController
            .open(url: url, options: .internalBrowser)
        
        completion?(true)
    }
}
