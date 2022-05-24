//
//  UIViewController.swift
//  iOS
//
//  Created by Anton Spivak on 02.02.2022.
//

import UIKit
import HuetonUI

extension UIViewController {
    
    struct ErrorPresentingOptions: OptionSet {
        
        var rawValue: Int
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let skipIfCancelled = ErrorPresentingOptions(rawValue: 1 << 0)
        
        static let `default`: ErrorPresentingOptions = [.skipIfCancelled]
    }
    
    func present(
        _ errorToPresent: Error,
        options: ErrorPresentingOptions = .default,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if options.contains(.skipIfCancelled) {
            if errorToPresent is CancellationError {
                return
            }
            if let errorToPresent = errorToPresent as? ApplicationError, errorToPresent == .userCancelled {
                return
            }
        }
        
        let viewController = AlertViewController(
            image: .image(.hui_error42, tintColor: .hui_letter_red),
            title: ":(",
            message: errorToPresent.localizedDescription,
            actions: [.done]
        )
        
        topmostPresentedViewController.present(viewController, animated: animated, completion: completion)
    }
    
    func presentUnderDevelopment(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let viewController = AlertViewController(
            image: .image(.hui_development42, tintColor: .hui_letter_purple),
            title: "UnderDevelopmentPromptTitle".asLocalizedKey,
            message: "UnderDevelopmentPromptMessage".asLocalizedKey,
            actions: [.ok]
        )
        
        topmostPresentedViewController.present(viewController, animated: animated, completion: completion)
    }
    
    enum URLPresentationOptions {
        
        case `default`
        case internalBrowser
        case web3
    }
    
    func hide(animated: Bool, popIfAvailable: Bool = true) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first == self || !popIfAvailable {
                navigationController.dismiss(animated: animated)
            } else {
                navigationController.popViewController(animated: animated)
            }
        } else {
            dismiss(animated: animated)
        }
    }
    
    func open(
        url: URL?,
        options: URLPresentationOptions = .default
    ) {
        guard let url = url
        else {
            return
        }
        
        switch options {
        case .default:
            UIApplication.shared.open(url)
        case .internalBrowser:
            let safariViewController = SafariViewController(url: url)
            present(safariViewController, animated: true)
        case .web3:
            let web3ViewController = Web3ViewController(url: url)
            present(web3ViewController, animated: true)
        }
    }
}
