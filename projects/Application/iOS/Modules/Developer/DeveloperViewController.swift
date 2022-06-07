//
//  DeveloperViewController.swift
//  iOS
//
//  Created by Anton Spivak on 02.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import MessageUI

class DeveloperViewController: C42CollectionViewController {
    
    init(
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        super.init(
            title: "DeveloperTitle".asLocalizedKey,
            sections: [
                // Description
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "DeveloperDescription".asLocalizedKey,
                            kind: .headline
                        ),
                    ]
                ),
                // Debug
                .init(
                    section: .init(
                        kind: .simple,
                        header: .none
                    ),
                    items: [
                        .asynchronousButton(
                            title: "DeveloperCopyAPNs".asLocalizedKey,
                            kind: .secondary,
                            action: { viewController in
                                InAppAnnouncementCenter.shared.post(
                                    announcement: InAppAnnouncementInfo.self,
                                    with: .init(text: "Token copied", icon: .copying, tintColor: .hui_letter_blue)
                                )
                                
                                guard let token = await PushIdentificator.shared.value
                                else {
                                    throw NotificationsPermissionError.notEnabledDeveloper
                                }
                                
                                UIPasteboard.general.string = token
                            }
                        ),
                        .synchronousButton(
                            title: "DeveloperClearAllDataButton".asLocalizedKey,
                            kind: .secondary,
                            action: { viewController in
                                (viewController as? DeveloperViewController)?.presentRemoveAllAction()
                            }
                        ),
                    ]
                ),
                // Application version
                .init(
                    section: .init(
                        kind: .simple,
                        header: .applicationVersion
                    ),
                    items: []
                ),
            ],
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
}

extension DeveloperViewController {
    
    fileprivate func presentRemoveAllAction() {
        let action = { @PersistenceWritableActor in
            let context = PersistenceWritableActor.shared.managedObjectContext
            let request = PersistenceAccount.fetchRequestSortingLastUsage()
            let result = try context.fetch(request)
            
            try result.forEach({
                try $0.delete()
            })
            
            let parole = SecureParole()
            try await parole.removeKey()
            
            UDS.isWelcomeScreenViewed = false
            UDS.isAgreementsAccepted = false
            
            fatalError("42")
        }
        
        let alertViewController = AlertViewController(
            image: .image(.hui_warning42, tintColor: .hui_letter_red),
            title: "CommonAttention".asLocalizedKey,
            message: "CommonUndoneAction".asLocalizedKey,
            actions: [
                .init(
                    title: "CommonYes".asLocalizedKey,
                    block: { viewController in
                        Task { try await action() }
                    },
                    style: .destructive
                ),
                .cancel
            ]
        )
        
        hui_present(alertViewController, animated: true)
    }
}

