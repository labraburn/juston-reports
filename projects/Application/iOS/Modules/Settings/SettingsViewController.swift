//
//  SettingsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI
import MessageUI

class SettingsViewController: SCLS3000ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        apply(
            snapshot: .settingsDefaultSnapshot(withViewController: self)
        )
    }
}

private extension NSDiffableDataSourceSnapshot where SectionIdentifierType == SCLS3000Section, ItemIdentifierType == SCLS3000Item {
    
    static func settingsDefaultSnapshot(
        withViewController viewController: SettingsViewController
    ) ->NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        
        // Logo & Version sections
        snapshot.appendSection(.init(kind: .list, header: .logo), items: [])
        snapshot.appendSection(.init(kind: .list, header: .applicationVersion), items: [])
        
        // General section
        snapshot.appendSection(
            .init(kind: .list, header: .title(value: "General")),
            items: [
                .init(kind: .text(value: "About"), synchronousAction: { }),
                .init(kind: .text(value: "Share"), synchronousAction: { [weak viewController] in
                    let items = [URL(string: "https://hueton.com")!]
                    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    viewController?.present(activityViewController, animated: true)
                }),
                .init(kind: .text(value: "Rate Us"), synchronousAction: { // [weak viewController] in
//                    let url = URL(string: "itms-apps://apple.com/app/id1601121482")!
//                    viewController.open(url: url)
                }),
                .init(kind: .text(value: "Notifications"), synchronousAction: { [weak viewController] in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    viewController?.open(url: url)
                })
            ]
        )
        
        // Agreements section
        snapshot.appendSection(
            .init(kind: .list, header: .title(value: "Agreements")),
            items: [
                .init(kind: .text(value: "Privacy Policy"), synchronousAction: { [weak viewController] in
                    let url = URL(string: "https://hueton.com/policy")
                    viewController?.open(url: url, options: .internalBrowser)
                }),
                .init(kind: .text(value: "Terms of Use"), synchronousAction: { [weak viewController] in
                    let url = URL(string: "https://hueton.com/terms")
                    viewController?.open(url: url, options: .internalBrowser)
                }),
            ]
        )
        
        // Support section
        snapshot.appendSection(
            .init(kind: .list, header: .title(value: "Support")),
            items: [
                .init(kind: .text(value: "Contact Developer"), synchronousAction: { [weak viewController] in
                    let email = "hello@hueton.com"
                    if MFMailComposeViewController.canSendMail() {
                        let mailComposeViewController = MFMailComposeViewController()
                        mailComposeViewController.mailComposeDelegate = viewController
                        mailComposeViewController.setToRecipients([email])
                        viewController?.present(mailComposeViewController, animated: true)
                    } else {
                        let url = URL(string: "mailto:\(email)")
                        viewController?.open(url: url)
                    }
                }),
                .init(kind: .text(value: "Open Chat"), synchronousAction: { [weak viewController] in
                    let url = URL(string: "https://t.me/hueton_chat")
                    viewController?.open(url: url)
                }),
            ]
        )
        
        // Social networks section
        snapshot.appendSection(
            .init(kind: .list, header: .title(value: "Social Networks")),
            items: [
                .init(kind: .text(value: "Telegram"), synchronousAction: { [weak viewController] in
                    let url = URL(string: "https://t.me/hueton3000")
                    viewController?.open(url: url)
                }),
                .init(kind: .text(value: "Twitter"), synchronousAction: { [weak viewController] in
                    let url = URL(string: "https://twitter.com/hueton3000")
                    viewController?.open(url: url, options: .internalBrowser)
                }),
            ]
        )
        
        // Debug section
        snapshot.appendSection(
            .init(kind: .list, header: .title(value: "Debug")),
            items: [
                .init(kind: .text(value: "Copy Device Token"), synchronousAction: {
                    UIPasteboard.general.string = PushIdentificator.shared.APNSToken
                }),
            ]
        )
        
        return snapshot
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
