//
//  Application.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

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
}
