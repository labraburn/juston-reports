//
//  UIViewController.swift
//  iOS
//
//  Created by Anton Spivak on 02.02.2022.
//

import UIKit
import HuetonUI

extension UIViewController {
    
    func presentAlertViewController(with error: Error, title: String? = "ERROR") {
        let viewController = AlertViewController(
            image: .hui_error42,
            title: title,
            message: error.localizedDescription,
            actions: [.done]
        )
        present(viewController, animated: true, completion: nil)
    }
}
