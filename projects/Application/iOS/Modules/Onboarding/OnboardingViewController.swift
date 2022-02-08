//
//  OnboardingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI
import SwiftyTON

protocol OnboardingViewControllerDelegate: AnyObject {
    
    func onboardingViewControllerDidComplete(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    
    weak var delegate: OnboardingViewControllerDelegate? = nil
    
    @IBOutlet weak var logoView: AnimatedLogoView!
    
    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.update(presentation: .on)
    }
    
    func setLoading(_ loading: Bool) {
        self.view.isUserInteractionEnabled = !loading
        if loading {
            self.logoView.startLoadingAnimation()
        } else {
            self.logoView.stopLoadingAnimation()
        }
        
        UIView.animate(withDuration: 0.12, animations: {
            self.createWalletButton.alpha = loading ? 0 : 1
            self.importWalletButton.alpha = loading ? 0 : 1
        }, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func createWalletButtonDidClick(_ sender: UIButton) {
        Task {
            self.setLoading(true)
            do {
                let result = try await Key.create(password: Data(), mnemonic: Data())
                
                let storage = SecureStorage()
                try await storage.save(key: result.0)
                
                print(result)

                self.setLoading(false)
                self.delegate?.onboardingViewControllerDidComplete(self)
            } catch {
                self.setLoading(false)
                self.presentAlertViewController(with: error)
            }
        }
    }
    
    @IBAction func importWalletButtonDidClick(_ sender: UIButton) {
        
    }
}
