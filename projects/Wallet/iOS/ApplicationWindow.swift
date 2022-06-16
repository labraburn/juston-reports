//
//  ApplicationWindow.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class ApplicationWindow: UIWindow {
    
    @available(*, unavailable, message: "Use `windowRootViewController` instead.")
    override var rootViewController: UIViewController? {
        set {
            guard newValue != nil
            else {
                super.rootViewController = newValue
                return
            }
            
            guard let viewController = newValue as? ApplicationWindowViewController
            else {
                fatalError("Could'nt use `\(String(describing: newValue))` as rootViewController in `ApplicationWindow`.")
            }
            
            super.rootViewController = viewController
        }
        get {
            super.rootViewController
        }
    }
    
    var windowRootViewController: ApplicationWindowViewController { super.rootViewController as! ApplicationWindowViewController }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        super.rootViewController = ApplicationWindowViewController()
        super.overrideUserInterfaceStyle = .dark
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
