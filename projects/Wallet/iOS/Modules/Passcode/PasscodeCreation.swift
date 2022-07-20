//
//  PasscodeCreation.swift
//  iOS
//
//  Created by Anton Spivak on 11.04.2022.
//

import UIKit
import JustonCORE
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
            containerViewController.jus_present(viewController, animated: true)
        })
        
        try await task.value
    }
}

extension PasscodeCreation: PasscodeViewControllerDelegate {

    @MainActor
    func passcodeViewController(_ viewController: PasscodeViewController, didFinishWithPasscode passcode: String) {
        viewController.dismiss(animated: true, completion: {
            Task {
                do {
                    try await self.parole.generateKeyWithUserPassword(passcode)
                    await self.passcodeContinuation?.resume(returning: ())
                } catch SecureParoleError.applicationIsSet {
                    await self.passcodeContinuation?.resume(returning: ())
                } catch {
                    await self.passcodeContinuation?.resume(throwing: error)
                }
            }
        })
    }
    
    @MainActor
    func passcodeViewControllerDidCancel(_ viewController: PasscodeViewController) {
        viewController.dismiss(animated: true, completion: {
            Task {
                await self.passcodeContinuation?.resume(throwing: ApplicationError.userCancelled)
            }
        })
    }
    
    @MainActor
    func passcodeViewControllerDidRequireBiometry(_ viewController: PasscodeViewController) {}
}
