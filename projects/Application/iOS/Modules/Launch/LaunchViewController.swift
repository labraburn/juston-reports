//
//  LaunchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI
import SwiftyTON

protocol LaunchViewControllerDelegate: AnyObject {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool)
}

extension AnimatedLogoView {
    
    static var applicationHeight = CGFloat(64)
    static var applicationWidth = CGFloat(169)
}

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var logoView: AnimatedLogoView!
    @IBOutlet weak var logoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: LaunchViewControllerDelegate? = nil
    
    private var isAppeared = false
    private var isAnimationFinished = false
    private var isTONInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        logoView.animate(
            with: [
                .off,
                .off,
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .off, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .on, f: .off, t: .off),
                .init(b: .on, l: .off, i: .off, f: .off, t: .off),
                .init(b: .on, l: .off, i: .on, f: .off, t: .on),
                .init(b: .on, l: .off, i: .on, f: .on, t: .on),
                .on,
            ],
            duration: 1.1,
            completion: { _ in }
        )
        
        self.logoViewTopConstraint.constant = 0
        self.logoViewHeightConstraint.constant = AnimatedLogoView.applicationHeight
        self.logoViewWidthConstraint.constant = AnimatedLogoView.applicationWidth
        
        UIView.animate(
            withDuration: 0.64,
            delay: 0.8,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            options: [.curveEaseOut],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.isAnimationFinished = true
                self.completeLoadingIfNeeded()
            }
        )
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
