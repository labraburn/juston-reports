//
//  LaunchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import HuetonUI
import SwiftyTON

protocol LaunchViewControllerDelegate: AnyObject {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool)
}

extension HuetonView {
    
    static var applicationHeight = CGFloat(18)
}

class LaunchViewController: UIViewController {
    
    private let huetonView = HuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    weak var delegate: LaunchViewControllerDelegate? = nil
    
    private var isAppeared = false
    private var isAnimationFinished = false
    private var isTONInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(huetonView)
        
        NSLayoutConstraint.activate {
            huetonView.heightAnchor.pin(to: HuetonView.applicationHeight)
            huetonView.centerXAnchor.pin(to: view.centerXAnchor)
            huetonView.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        }
        
        Task {
            do {
                try await SwiftyTONConfigurate(.main)

                self.isTONInitialized = true
                self.completeLoadingIfNeeded()
            } catch {
                self.presentAlertViewController(
                    with: error,
                    title: "Can't initialize TON. :("
                )
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !isAppeared
        else {
            return
        }
        
        isAppeared = true
        
        huetonView.performUpdatesWithLetters({ updates in
            updates.trigger()
        }, completion: { _ in
            self.isAnimationFinished = true
            self.completeLoadingIfNeeded()
        })
    }
    
    // MARK: Private
    
    private func completeLoadingIfNeeded() {
        guard isTONInitialized, isAnimationFinished
        else {
            return
        }
        
        delegate?.launchViewController(self, didFinishAnimation: true)
    }
}
