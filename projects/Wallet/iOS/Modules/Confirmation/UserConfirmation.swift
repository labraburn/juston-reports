//
//  UserConfirmation.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import SwiftyTON

actor UserConfirmation {
    
    enum ConfirmationAction {
        
        case sign(host: String)
        case transaction(host: String, destination: DisplayableAddress, value: Currency)
        case largeTransactionUnbouncableAddress
    }
    
    private var continuation: CheckedContinuation<(), Error>?
    
    let confirmationAction: ConfirmationAction
    let presentationContext: UIViewController
    
    init(
        _ action: ConfirmationAction,
        presentationContext viewController: UIViewController
    ) {
        confirmationAction = action
        presentationContext = viewController
    }
    
    func confirm() async throws {
        let task = Task<(), Error> {
            try await withCheckedThrowingContinuation({ continuation in
                self.continuation = continuation
            })
        }
        
        let action = confirmationAction
        
        await MainActor.run(body: {
            let viewController = action.viewController(with: { [weak self] allowed in
                Task {
                    if allowed {
                        await self?.continuation?.resume(returning: ())
                    } else {
                        await self?.continuation?.resume(throwing: WKWeb3Error(.userRejectedRequest))
                    }
                }
            })
            
            presentationContext.jus_present(
                viewController,
                animated: true
            )
        })
        
        return try await task.value
    }
}

private extension UserConfirmation.ConfirmationAction {
    
    func viewController(
        with completionBlock: @escaping (_ allowed: Bool) -> ()
    ) -> UIViewController {
        
        let image: AlertViewControllerImage
        let message: String
        
        switch self {
        case let .sign(host):
            image = .image(.jus_warning42, tintColor: .jus_letter_yellow)
            message = String(format: "UserConfirmationSignMessage".asLocalizedKey, host.uppercased())
        case let .transaction(host, destination, value):
            image = .image(.jus_warning42, tintColor: .jus_letter_red)
            message = String(
                format: "UserConfirmationTransactionMessage".asLocalizedKey,
                host.uppercased(),
                value.string(with: .maximum9),
                destination.displayName
            )
        case .largeTransactionUnbouncableAddress:
            image = .image(.jus_warning42, tintColor: .jus_letter_yellow)
            message = "UserConfirmationLargeAmountUnbouncableAddress".asLocalizedKey
        }
        
        return AlertViewController(
            image: image,
            title: "UserConfirmationTitle".asLocalizedKey,
            message: message,
            actions: [
                .init(
                    title: "UserConfirmationConfirmButton".asLocalizedKey,
                    block: { viewController in
                        viewController.hide(animated: true)
                        completionBlock(true)
                    },
                    style: .default
                ),
                .init(
                    title: "CommonCancel".asLocalizedKey,
                    block: { viewController in
                        viewController.hide(animated: true)
                        completionBlock(false)
                    },
                    style: .cancel
                )
            ]
        )
    }
}
