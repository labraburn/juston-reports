//
//  UIViewController.swift
//  iOS
//
//  Created by Anton Spivak on 02.02.2022.
//

import UIKit

extension UIViewController {
    
    func presentAlertViewController(with error: Error, title: String? = "ERROR") {
        let viewController = UIAlertController(
            title: title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        viewController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(viewController, animated: true, completion: nil)
    }
}
