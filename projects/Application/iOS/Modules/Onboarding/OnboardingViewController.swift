//
//  OnboardingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI

protocol OnboardingViewControllerDelegate: AnyObject {
    
    func onboardingViewControllerDidComplete(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    
    weak var delegate: OnboardingViewControllerDelegate? = nil
    
    struct Step {}
    
    @IBOutlet weak var logoView: AnimatedLogoView!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.update(presentation: .on)
    }
    
    // MARK: Actions
    
    @IBAction func continueButtonDidClick(_ sender: UIButton) {
        
    }
}
