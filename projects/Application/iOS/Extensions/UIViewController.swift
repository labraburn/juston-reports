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
        if errorToPresent is CancellationError && options.contains(.skipIfCancelled) {
            return
        }
        
        let viewController = AlertViewController(
            image: .image(.hui_error42, tintColor: .hui_letter_red),
            title: ":(",
            message: errorToPresent.localizedDescription,
            actions: [.done]
        )
        
        present(viewController, animated: animated, completion: completion)
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
        
        present(viewController, animated: animated, completion: completion)
    }
}
