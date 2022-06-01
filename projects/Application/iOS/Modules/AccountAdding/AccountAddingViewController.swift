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
import CoreData

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
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: .hui_placeholderV4512
                        ),
                        .label(
                            text: "AccountAddingIOCDescription".asLocalizedKey,
                            kind: .body
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .synchronousButton(
                            title: "AccountAddingImportButton".asLocalizedKey,
                            kind: .secondary,
                            action: { viewController in
                                viewController.next(.import)
                            }
                        ),
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
                    ]
                )
            ],
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }

    static var `import`: SteppableViewModel {
        var result: SteppableImportAccountCollectionCell.Result? = nil
        return SteppableViewModel(
            title: "AccountAddingImportTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "AccountAddingImportDescription".asLocalizedKey,
                            kind: .body
                        ),
                        .importAccountTextField(
                            uuid: UUID(),
                            action: { _result in
                                result = _result
                            }
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .asynchronousButton(
                            title: "AccountAddingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { @MainActor viewController in
                                var keyPublic: String? = nil
                                var keySecretEncrypted: String? = nil
                                let selectedAddress: Address
                                
                                let context = PersistenceReadableActor.shared.managedObjectContext
                                
                                switch result {
                                case let .address(value):
                                    let contract = try await Contract(rawAddress: value.rawValue)
                                    if contract.kind != .uninitialized {
                                        let data = (try? await contract.execute(methodNamed: "get_public_key").asBigUInt())?.serialize()
                                        keyPublic = data?.toHexString()
                                    }
                                    selectedAddress = value
                                case let .words(value):
                                    let authentication = PasscodeAuthentication(inside: viewController)
                                    let passcode = try await authentication.key()
                                    let key = try await Key.import(password: passcode, words: value)
                                    
                                    keyPublic = try key.deserializedPublicKey().toHexString()
                                    keySecretEncrypted = key.encryptedSecretKey.toHexString()
                                    selectedAddress = try await Address(
                                        initial: try await Wallet3.initial(key: key)
                                    )
                                case .none:
                                    return
                                }
                                
                                let request: NSFetchRequest<PersistenceAccount>
                                if let keyPublic = keyPublic {
                                    request = PersistenceAccount.fetchRequest(keyPublic: keyPublic)
                                } else {
                                    request = PersistenceAccount.fetchRequest(selectedAddress: selectedAddress)
                                }
                                
                                let result = (try? context.fetch(request))?.first
                                if let account = result {
                                    throw AccountError.accountExists(name: account.name)
                                }
                                
                                viewController.next(
                                    .appearance(
                                        keyPublic: keyPublic,
                                        keySecretEncrypted: keySecretEncrypted,
                                        selectedAddress: selectedAddress
                                    )
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
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "AccountAddingWordsDescription1".asLocalizedKey,
                            kind: .headline
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .words
                    ),
                    items: { () -> [SteppableItem] in
                        var result = [SteppableItem]()
                        var index = 1
                        words.forEach({
                            result.append(.word(index: index, word: $0))
                            index += 1
                        })
                        return result
                    }()
                ),
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "AccountAddingWordsDescription2".asLocalizedKey,
                            kind: .body
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .synchronousButton(
                            title: "AccountAddingCopyButton".asLocalizedKey,
                            kind: .secondary,
                            action: { _ in
                                InAppAnnouncementCenter.shared.post(
                                    announcement: InAppAnnouncementInfo.self,
                                    with: .wordsCopied
                                )
                                
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = words.joined(separator: " ")
                            }
                        ),
                        .synchronousButton(
                            title: "AccountAddingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.next(
                                    .appearance(
                                        keyPublic: try key.deserializedPublicKey().toHexString(),
                                        keySecretEncrypted: key.encryptedSecretKey.toHexString(),
                                        selectedAddress: address
                                    )
                                )
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }
}

private extension SteppableViewGenericModel {
    
    static func appearance(
        keyPublic: String?,
        keySecretEncrypted: String?,
        selectedAddress: Address
    ) -> SteppableViewGenericModel {
        SteppableViewGenericModel(
            title: "AccountAddingAppearanceTitle".asLocalizedKey,
            viewController: { navigationController in
                CreatingAccountAppearenceViewController(
                    completionBlock: { [weak navigationController] name, appearence in
                        let account = await PersistenceAccount(
                            keyPublic: keyPublic,
                            keySecretEncrypted: keySecretEncrypted,
                            selectedAddress: selectedAddress,
                            name: name,
                            appearance: appearence
                        )

                        try await account.saveAsLastSorting()
                        try await account.saveAsLastUsage()

                        // TODO: Fix this weird code
                        navigationController?.dismiss(animated: true)
                    }
                )
            },
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }
}
