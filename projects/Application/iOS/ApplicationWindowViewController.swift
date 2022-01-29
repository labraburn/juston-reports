//
//  ApplicationWindowViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI

class ApplicationWindowViewController: LevelViewController {
    
//    override var prefersStatusBarHidden: Bool { true }
//    override var childForStatusBarHidden: UIViewController? { nil }
    
    private let backgroundImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
    }
    
    @available(*, unavailable, message: "Use `exhange(_ viewControllerToPresent:at:animated:completion:)` instead.")
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        fatalError("Use `exhange(_ viewControllerToPresent:at:animated:completion:)` instead.")
    }

    @available(*, unavailable, message: "Root view controller of window can not been dismissed.")
    public override func dismiss(animated flag: Bool,completion: (() -> Void)? = nil) {
        guard presentedViewController != nil
        else {
            fatalError("Root view controller of window can not been dismissed.")
        }
        
        super.dismiss(animated: flag, completion: completion)
    }
}

extension UIView {
    
    var applicationWindow: ApplicationWindow? {
        window as? ApplicationWindow
    }
}

extension UIViewController {
    
    ///
    /// Simplified method for self-dismissal
    ///
    func dismissFromApplicationWindowViewControllerIfNecessary(animated: Bool, completion: (() -> Void)? = nil) {
        guard let window = view.applicationWindow,
              let indexOfSelf = window.windowRootViewController.viewControllers.firstIndex(of: self)
        else {
            return
        }
        
        window.windowRootViewController.exchange(
            nil,
            at: ApplicationWindowViewController.Level(rawValue: indexOfSelf),
            animated: animated,
            completion: nil
        )
    }
}
