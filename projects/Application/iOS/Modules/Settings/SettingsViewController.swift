//
//  SettingsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import MessageUI

class SettingsViewController: C42CollectionViewController, MFMailComposeViewControllerDelegate {
    
    init(
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = true
    ) {
        super.init(
            title: "Settings",
            sections: [
                // Application logo
                .init(
                    section: .init(
                        kind: .simple,
                        header: .logo
                    ),
                    items: []
                ),
                // Application version
                .init(
                    section: .init(
                        kind: .simple,
                        header: .applicationVersion
                    ),
                    items: []
                ),
                // General
                .init(
                    section: .init(
                        kind: .simple,
                        header: .none
                    ),
                    items: [
                        .synchronousButton(
                            title: "About",
                            kind: .secondary,
                            action: { _ in }
                        ),
                        .synchronousButton(
                            title: "Share",
                            kind: .secondary,
                            action: { viewController in
                                let items = [URL(string: "https://hueton.com")!]
                                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                viewController.present(activityViewController, animated: true)
                            }
                        ),
                        .synchronousButton(
                            title: "Rate Us",
                            kind: .secondary,
                            action: { _ in
    //                            let url = URL(string: "itms-apps://apple.com/app/id1601121482")!
    //                            viewController.open(url: url)
                            }
                        ),
                        .synchronousButton(
                            title: "Notifications",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: UIApplication.openSettingsURLString)
                                viewController.open(url: url)
                            }
                        ),
                    ]
                ),
                // Agreements
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "Agreements"
                        )
                    ),
                    items: [
                        .synchronousButton(
                            title: "Privacy Policy",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: "https://hueton.com/policy")
                                viewController.open(url: url, options: .internalBrowser)
                            }
                        ),
                        .synchronousButton(
                            title: "Terms of Use",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: "https://hueton.com/terms")
                                viewController.open(url: url, options: .internalBrowser)
                            }
                        ),
                    ]
                ),
                // Support
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "Support"
                        )
                    ),
                    items: [
                        .synchronousButton(
                            title: "Contact Developer",
                            kind: .secondary,
                            action: { viewController in
                                let email = "hello@hueton.com"
                                if MFMailComposeViewController.canSendMail() {
                                    let mailComposeViewController = MFMailComposeViewController()
                                    mailComposeViewController.mailComposeDelegate = viewController as? SettingsViewController
                                    mailComposeViewController.setToRecipients([email])
                                    viewController.present(mailComposeViewController, animated: true)
                                } else {
                                    let url = URL(string: "mailto:\(email)")
                                    viewController.open(url: url)
                                }
                            }
                        ),
                        .synchronousButton(
                            title: "Open Chat",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: "https://t.me/hueton_chat")
                                viewController.open(url: url)
                            }
                        ),
                    ]
                ),
                // Social networks
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "Social Networks"
                        )
                    ),
                    items: [
                        .synchronousButton(
                            title: "Telegram",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: "https://t.me/hueton3000")
                                viewController.open(url: url)
                            }
                        ),
                        .synchronousButton(
                            title: "Twitter",
                            kind: .secondary,
                            action: { viewController in
                                let url = URL(string: "https://twitter.com/hueton3000")
                                viewController.open(url: url, options: .internalBrowser)
                            }
                        ),
                    ]
                ),
                // Debug
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "Debug"
                        )
                    ),
                    items: [
                        .synchronousButton(
                            title: "Copy device push token",
                            kind: .secondary,
                            action: { viewController in
                                UIPasteboard.general.string = PushIdentificator.shared.APNSToken
                            }
                        ),
                        .synchronousButton(
                            title: "Clear all data",
                            kind: .teritary,
                            action: { viewController in
                                let alertViewController = AlertViewController(
                                    image: .image(.hui_warning42, tintColor: .hui_letter_red),
                                    title: "CommonAttention".asLocalizedKey,
                                    message: "CommonUndoneAction".asLocalizedKey,
                                    actions: [
                                        .init(
                                            title: "CommonYes".asLocalizedKey,
                                            block: { viewController in
                                                Task { @PersistenceWritableActor in
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
                                            },
                                            style: .destructive
                                        ),
                                        .cancel
                                    ]
                                )
                                
                                viewController.hui_present(alertViewController, animated: true)
                            }
                        )
                    ]
                ),
            ],
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
