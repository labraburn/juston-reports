//
//  AccountAddingNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import SystemUI
import HuetonUI
import HuetonCORE

class AccountAddingViewController: SteppableNavigationController {
    
    init() {
        super.init(rootViewModel: .initial)
    }
}

private extension SteppableViewModel {
    
    static var initial: SteppableViewModel {
        SteppableViewModel(
            title: "AccountAddingIOCTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .image(
                            image: .hui_placeholder512
                        ),
                        .label(
                            text: "AccountAddingIOCDescription".asLocalizedKey
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .asynchronousButton(
                            title: "AccountAddingCreateButton".asLocalizedKey,
                            kind: .primary,
                            action: { @MainActor viewController in
                                let authentication = PasscodeAuthentication(inside: viewController)
                                let passcode = try await authentication.key()
                                
                                let key = try await Key.create(password: passcode)
                                let words = try await key.words(password: passcode)
                                
                                let initial = try await Wallet3.initial(key: key)
                                let address = try await Address(initial: initial)
                                
                                viewController.next(
                                    .words(for: key, address: address, words: words)
                                )
                            }
                        ),
                        .synchronousButton(
                            title: "AccountAddingImportButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.next(.import)
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }

    static var `import`: SteppableViewModel {
        // TODO: Should be reworked
        var address = ""
        return SteppableViewModel(
            title: "AccountAddingImportTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .label(
                            text: "AccountAddingImportDescription".asLocalizedKey
                        ),
                        .textField(
                            title: "Public key".asLocalizedKey,
                            placeholder: "Text key here".asLocalizedKey,
                            action: { textField in
                                address = textField.text ?? ""
                            }
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "AccountAddingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                guard let address = Address(string: address)
                                else {
                                    return
                                }

                                viewController.next(
                                    .appearance(for: nil, address: address, flags: .readonly)
                                )
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }

    static func words(
        `for` key: Key,
        address: Address,
        words: [String]
    ) -> SteppableViewModel {
        SteppableViewModel(
            title: "AccountAddingWordsTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .label(
                            text: "AccountAddingWordsDescription".asLocalizedKey
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .words),
                    items: { () -> [SteppableItem] in
                        var result = [SteppableItem]()
                        var index = 0
                        words.forEach({
                            result.append(.word(index: index, word: $0))
                            index += 1
                        })
                        return result
                    }()
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "AccountAddingCopyButton".asLocalizedKey,
                            kind: .primary,
                            action: { _ in
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = words.joined(separator: " ")
                            }
                        ),
                        .synchronousButton(
                            title: "AccountAddingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.next(
                                    .appearance(for: key, address: address, flags: [])
                                )
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: false
        )
    }

    static func appearance(
        for key: Key?,
        address: Address,
        flags: PersistenceAccount.Flags
    ) -> SteppableViewModel {
        var name = ""
        return SteppableViewModel(
            title: "AccountAddingAppearanceTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .textField(
                            title: "AccountAddingAccountNameTitle".asLocalizedKey,
                            placeholder: "AccountAddingAccountNamePlaceholder".asLocalizedKey,
                            action: { textField in
                                name = textField.text ?? ""
                            }
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "AccountAddingDoneButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                guard !name.isEmpty
                                else {
                                    return
                                }
                                
                                let account: PersistenceAccount
                                if let key = key {
                                    account = PersistenceAccount(
                                        keyPublic: key.publicKey,
                                        keySecretEncrypted: key.encryptedSecretKey.toHexString(),
                                        selectedAddress: address,
                                        name: name,
                                        appearance: .default,
                                        subscriptions: [],
                                        flags: flags
                                    )
                                } else {
                                    account = PersistenceAccount(
                                        selectedAddress: address,
                                        name: name,
                                        appearance: .default,
                                        subscriptions: [],
                                        flags: flags
                                    )
                                }
                                
                                try account.saveAsLastSorting()
                                try account.saveAsLastUsage()
                                
                                viewController.finish()
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: true,
            isBackActionAvailable: true
        )
    }
}
