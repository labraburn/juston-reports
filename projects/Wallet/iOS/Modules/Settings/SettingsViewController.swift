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

class SettingsViewController: C42CollectionViewController {
    
    init(
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        super.init(
            title: "SettingsTitle".asLocalizedKey,
            sections: [
                // Application logo
                .init(
                    section: .init(
                        kind: .simple,
                        header: .logo(
                            secretAction: { viewController in
                                (viewController as? SettingsViewController)?.openDeveloperViewController()
                            }
                        )
                    ),
                    items: []
                ),
                // Description
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .text(
                            value: "SettingsDescription".asLocalizedKey,
                            numberOfLines: 0,
                            textAligment: .center
                        )
                    ]
                ),
                // General
                .init(
                    section: .init(
                        kind: .simple,
                        header: .none
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsShareButton".asLocalizedKey,
                            titleColor: .hui_letter_blue,
                            action: { viewController in
                                let items = [URL.hueton]
                                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                viewController.hui_present(activityViewController, animated: true)
                            }
                        ),
                        .settingsButton(
                            title: "SettingsRateButton".asLocalizedKey,
                            titleColor: .hui_letter_blue,
                            action: { viewController in
                                viewController.open(url: .appStore)
                            }
                        ),
                    ]
                ),
                // System settings
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSystemSettingsTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .hui_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsNotificationsButton".asLocalizedKey,
                            titleColor: .hui_letter_purple,
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
                            value: "SettingsAgreementsTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .hui_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsPrivacyPolicyButton".asLocalizedKey,
                            titleColor: .hui_letter_violet,
                            action: { viewController in
                                viewController.open(
                                    url: .privacyPolicy,
                                    options: .internalBrowser
                                )
                            }
                        ),
                        .settingsButton(
                            title: "SettingsTermsOfUseButton".asLocalizedKey,
                            titleColor: .hui_letter_violet,
                            action: { viewController in
                                viewController.open(
                                    url: .termsOfUse,
                                    options: .internalBrowser
                                )
                            }
                        ),
                    ]
                ),
                // Support
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSupportTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .hui_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsContactDeveloperButton".asLocalizedKey,
                            titleColor: .hui_letter_yellow,
                            action: { viewController in
                                (viewController as? SettingsViewController)?.openMailComposeViewControllerIfAvailable()
                            }
                        ),
                        .settingsButton(
                            title: "SettingsCommunityChatButton".asLocalizedKey,
                            titleColor: .hui_letter_yellow,
                            action: { viewController in
                                viewController.open(url: .telegramChat)
                            }
                        ),
                    ]
                ),
                // Social networks
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSocialTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .hui_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsTelegramButton".asLocalizedKey,
                            titleColor: .hui_letter_green,
                            action: { viewController in
                                viewController.open(url: .telegramChannel)
                            }
                        ),
                        .settingsButton(
                            title: "SettingsTwitterButton".asLocalizedKey,
                            titleColor: .hui_letter_green,
                            action: { viewController in
                                viewController.open(
                                    url: .twitter,
                                    options: .internalBrowser
                                )
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
}

extension SettingsViewController {
    
    func openDeveloperViewController() {
        next(DeveloperViewController())
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func openMailComposeViewControllerIfAvailable() {
        let email = "hello@hueton.com"
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([email])
            hui_present(mailComposeViewController, animated: true)
        } else {
            let url = URL(string: "mailto:\(email)")
            open(url: url)
        }
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
