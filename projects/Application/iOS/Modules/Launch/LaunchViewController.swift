//
//  LaunchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import HuetonUI

protocol LaunchViewControllerDelegate: AnyObject {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool)
}

extension HuetonView {
    
    static var applicationHeight = CGFloat(20)
}

class LaunchViewController: UIViewController {
    
    private let huetonView = HuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    weak var delegate: LaunchViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(huetonView)
        
        NSLayoutConstraint.activate {
            huetonView.heightAnchor.pin(to: HuetonView.applicationHeight)
            huetonView.centerXAnchor.pin(to: view.centerXAnchor)
            huetonView.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        huetonView.performUpdatesWithLetters({ updates in
            updates.trigger()
        }, completion: { _ in
            self.completeLoading()
        })
    }
    
    // MARK: Private
    
    private func completeLoading() {
        delegate?.launchViewController(self, didFinishAnimation: true)
    }
}
