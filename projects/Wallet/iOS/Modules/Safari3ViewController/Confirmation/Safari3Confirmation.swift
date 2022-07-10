//
//  Safari3Confirmation.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import SwiftyTON

actor Safari3Confirmation {
    
    enum ConfirmationAction {
        
        case sign(host: String)
        case transaction(host: String, destination: DisplayableAddress, value: Currency)
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
            
            presentationContext.hui_present(
                viewController,
                animated: true
            )
        })
        
        return try await task.value
    }
}

private extension Safari3Confirmation.ConfirmationAction {
    
    func viewController(
        with completionBlock: @escaping (_ allowed: Bool) -> ()
    ) -> UIViewController {
        
        let image: AlertViewControllerImage
        let message: String
        
        switch self {
        case let .sign(host):
            image = .image(.hui_warning42, tintColor: .hui_letter_yellow)
            message = String(format: "Safari3ConfirmationSignMessage".asLocalizedKey, host.uppercased())
        case let .transaction(host, destination, value):
            image = .image(.hui_warning42, tintColor: .hui_letter_red)
            message = String(
                format: "Safari3ConfirmationTransactionMessage".asLocalizedKey,
                host.uppercased(),
                value.string(with: .maximum9),
                destination.displayName
            )
        }
        
        return AlertViewController(
            image: image,
            title: "Safari3ConfirmationTitle".asLocalizedKey,
            message: message,
            actions: [
                .init(
                    title: "Safari3ConfirmationConfirmButton".asLocalizedKey,
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
