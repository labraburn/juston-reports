//
//  LaunchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI

protocol LaunchViewControllerDelegate: AnyObject {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool)
}

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var logoView: AnimatedLogoView!
    weak var delegate: LaunchViewControllerDelegate? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logoView.animate(
            with: [
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .off, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .on, f: .off, t: .off),
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .on, f: .off, t: .on),
                .init(b: .on, l: .off, i: .on, f: .on, t: .on),
                .init(b: .on, l: .on, i: .on, f: .on, t: .on),
            ],
            duration: 1.2,
            completion: { finished in
                self.laucnhDidComplete(finished)
            }
        )
    }
    
    // MARK: Private
    
    private func laucnhDidComplete(_ finished: Bool) {
        delegate?.launchViewController(self, didFinishAnimation: finished)
    }
}
