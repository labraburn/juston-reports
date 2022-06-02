//
//  OnboardingNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import SystemUI
import HuetonUI
import HuetonCORE
import CoreData

class OnboardingNavigationController: C42NavigationController {
    
    let initialConfiguration: InitialConfiguration
    
    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        
        let rootViewController: C42ViewController
        let screens = initialConfiguration.screens
        
        if screens.contains(.welcome) {
            rootViewController = C42CollectionViewController.onboardingWelcome()
        } else if screens.contains(.agreements) {
            rootViewController = C42CollectionViewController.onboardingAgreements()
        } else if screens.contains(.passcode) {
            rootViewController = C42CollectionViewController.onboardingPasscode()
        } else if screens.contains(.account) {
            rootViewController = C42CollectionViewController.onboardingIOCAccount()
        } else {
            fatalError("Screens is empty")
        }
        
        super.init(rootViewController: rootViewController)
    }
    
    // MARK: Agreements
    
    fileprivate func nextAgreementsIfNeeded() {
        if initialConfiguration.screens.contains(.agreements) {
            next(
                C42CollectionViewController.onboardingAgreements()
            )
        } else {
            nextCreatePasscodeIfNeeded()
        }
        
    }
    
    fileprivate func nextCreatePasscodeIfNeeded() {
        if initialConfiguration.screens.contains(.passcode) {
            next(
                C42CollectionViewController.onboardingPasscode()
            )
        } else {
            nextAccountIOC()
        }
    }
    
    // MARK: Onboarding
    
    fileprivate func nextAccountIOC() {
        next(
            C42CollectionViewController.onboardingIOCAccount()
        )
    }
    
    fileprivate func nextAccountImport() {
        next(
            C42ConcreteViewController.onboardingImportAccount()
        )
    }
    
    fileprivate func nextAccountCreate(
        key: Key,
        address: Address,
        words: [String]
    ) {
        next(
            C42CollectionViewController.onboardingPassphrase(
                for: key,
                address: address,
                words: words
            )
        )
    }
    
    fileprivate func nextAccountAppearance(
        keyPublic: String?,
        keySecretEncrypted: String?,
        selectedAddress: Address
    ) {
        next(
            C42ConcreteViewController.appearance(
                keyPublic: keyPublic,
                keySecretEncrypted: keySecretEncrypted,
                selectedAddress: selectedAddress
            )
        )
    }
}

private extension C42ViewController {
    
    var onboardingNavigationController: OnboardingNavigationController? {
        navigationController as? OnboardingNavigationController
    }
}

extension C42CollectionViewController {
    
    static func onboardingWelcome() -> C42CollectionViewController {
        C42CollectionViewController(
            title: "OnboardingWelcomeTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: .hui_placeholderV2512
                        ),
                        .label(
                            text: "OnboardingWelcomeDescription".asLocalizedKey,
                            kind: .body
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "OnboardingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                UDS.isWelcomeScreenViewed = true
                                viewController.onboardingNavigationController?.nextAgreementsIfNeeded()
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: false
        )
    }
    
    static func onboardingAgreements() -> C42CollectionViewController {
        C42CollectionViewController(
            title: "OnboardingAgreementsTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: .hui_placeholderV3512
                        ),
                        .label(
                            text: "OnboardingAgreementsDescription".asLocalizedKey,
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
                            title: "OnboardingAgreementsActionButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                UDS.isAgreementsAccepted = true
                                viewController.onboardingNavigationController?.nextCreatePasscodeIfNeeded()
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: false
        )
    }
    
    static func onboardingPasscode() -> C42CollectionViewController {
        C42CollectionViewController(
            title: "OnboardingPasscodeTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: .hui_placeholderV1512
                        ),
                        .label(
                            text: "OnboardingPasscodeDescription".asLocalizedKey,
                            kind: .body
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .asynchronousButton(
                            title: "OnboardingPasscodeActionButton".asLocalizedKey,
                            kind: .primary,
                            action: { @MainActor viewController in
                                let passcode = PasscodeCreation(inside: viewController)
                                try await passcode.create()
                                viewController.onboardingNavigationController?.nextAccountIOC()
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: false
        )
    }
    
    static func onboardingIOCAccount() -> C42CollectionViewController {
        C42CollectionViewController(
            title: "OnboardingIOCTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: .hui_placeholderV5512
                        ),
                        .label(
                            text: "OnboardingIOCDescription".asLocalizedKey,
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
                            title: "OnboardingImportButton".asLocalizedKey,
                            kind: .secondary,
                            action: { viewController in
                                viewController.onboardingNavigationController?.nextAccountImport()
                            }
                        ),
                        .asynchronousButton(
                            title: "OnboardingCreateButton".asLocalizedKey,
                            kind: .primary,
                            action: { @MainActor viewController in
                                let authentication = PasscodeAuthentication(inside: viewController)
                                let passcode = try await authentication.key()
                                
                                let key = try await Key.create(password: passcode)
                                let words = try await key.words(password: passcode)
                                
                                let initial = try await Wallet3.initial(key: key)
                                let address = try await Address(initial: initial)
                                
                                viewController.onboardingNavigationController?.nextAccountCreate(
                                    key: key,
                                    address: address,
                                    words: words
                                )
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: false,
            isBackActionAvailable: false
        )
    }
    
    static func onboardingPassphrase(
        `for` key: Key,
        address: Address,
        words: [String]
    ) -> C42CollectionViewController {
        C42CollectionViewController(
            title: "OnboardingWordsTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "OnboardingWordsDescription1".asLocalizedKey,
                            kind: .headline
                        ),
                    ]
                ),
                .init(
                    section: .init(
                        kind: .words
                    ),
                    items: { () -> [C42Item] in
                        var result = [C42Item]()
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
                            text: "OnboardingWordsDescription2".asLocalizedKey,
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
                            title: "OnboardingCopyButton".asLocalizedKey,
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
                            title: "OnboardingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.onboardingNavigationController?.nextAccountAppearance(
                                    keyPublic: try key.deserializedPublicKey().toHexString(),
                                    keySecretEncrypted: key.encryptedSecretKey.toHexString(),
                                    selectedAddress: address
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

extension C42ConcreteViewController {
    
    static func onboardingImportAccount(
    ) -> C42ConcreteViewController {
        OnboardingAccountImportViewController(
            completionBlock: { @MainActor viewController, result in
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
                
                viewController.onboardingNavigationController?.nextAccountAppearance(
                    keyPublic: keyPublic,
                    keySecretEncrypted: keySecretEncrypted,
                    selectedAddress: selectedAddress
                )
            },
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }
    
    static func appearance(
        keyPublic: String?,
        keySecretEncrypted: String?,
        selectedAddress: Address
    ) -> C42ConcreteViewController {
        OnboardingAccountAppearenceViewController(
            title: "OnboardingAppearanceTitle".asLocalizedKey,
            completionBlock: { viewController, name, appearence in
                let account = await PersistenceAccount(
                    keyPublic: keyPublic,
                    keySecretEncrypted: keySecretEncrypted,
                    selectedAddress: selectedAddress,
                    name: name,
                    appearance: appearence
                )

                try await account.saveAsLastSorting()
                try await account.saveAsLastUsage()

                viewController.finish()
            },
            isModalInPresentation: false,
            isBackActionAvailable: true
        )
    }
}
