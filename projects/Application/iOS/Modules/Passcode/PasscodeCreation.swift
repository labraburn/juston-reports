//
//  PasscodeCreation.swift
//  iOS
//
//  Created by Anton Spivak on 11.04.2022.
//

import UIKit
import HuetonCORE
import LocalAuthentication

actor PasscodeCreation {

    let containerViewController: UIViewController
    
    private let parole: SecureParole
    private var passcodeContinuation: CheckedContinuation<(), Error>?
    
    init(inside viewController: UIViewController) {
        parole = SecureParole()
        containerViewController = viewController
    }
    
    func create() async throws {
        let task = Task<(), Error> {
            try await withCheckedThrowingContinuation({ continuation in
                self.passcodeContinuation = continuation
            })
        }
        
        await MainActor.run(body: {
            let viewController = PasscodeViewController(mode: .create)
            viewController.delegate = self
            viewController.isModalInPresentation = true
            containerViewController.hui_present(viewController, animated: true)
        })
        
        try await task.value
    }
}

extension PasscodeCreation: PasscodeViewControllerDelegate {

    @MainActor
    func passcodeViewController(_ viewController: PasscodeViewController, didFinishWithPasscode passcode: String) {
        Task {
            viewController.dismiss(animated: true)
            
            do {
                try await parole.generateKeyWithUserPassword(passcode)
                await passcodeContinuation?.resume(returning: ())
            } catch {
                await passcodeContinuation?.resume(throwing: error)
            }
        }
    }
    
    @MainActor
    func passcodeViewControllerDidCancel(_ viewController: PasscodeViewController) {
        Task {
            viewController.dismiss(animated: true)
            await passcodeContinuation?.resume(throwing: ApplicationError.userCancelled)
        }
    }
    
    @MainActor
    func passcodeViewControllerDidRequireBiometry(_ viewController: PasscodeViewController) {}
}
