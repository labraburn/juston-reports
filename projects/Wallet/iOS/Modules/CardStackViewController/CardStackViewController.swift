//
//  CardStackViewController.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import DefaultMOON
import CoreData

extension DefaultMOON {
    
    static let shared = DefaultMOON()
}

protocol CardStackViewControllerDelegate: AnyObject {
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didChangeSelectedModel model: CardStackCard?
    )
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didClickAtModel model: CardStackCard?
    )
}

class CardStackViewController: UIViewController {
    
    private var fetchResultsController: NSFetchedResultsController<PersistenceAccount>?
    private var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    private var task: Task<(), Never>?
    
    var cardStackView: CardStackView { view as! CardStackView }
    
    var cards: [CardStackCard] { cardStackView.cards }
    var selectedCard: CardStackCard? { cardStackView.selected }
    
    weak var delegate: CardStackViewControllerDelegate?
    
    override func loadView() {
        let view = CardStackView()
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = PersistenceAccount.fetchRequestSortingLastUsage()
        fetchResultsController = PersistenceAccount.fetchedResultsController(request: fetchRequest)
        fetchResultsController?.delegate = self

        try? fetchResultsController?.performFetch()
    }
    
    // MARK: Actions
    
    func showSwitchAccount(to kind: Contract.Kind, model: CardStackCard) {
        guard model.account.contractKind != kind
        else {
            return
        }
        
        guard let publicKey = model.account.keyPublic
        else {
            let error = ContractError.unknownContractType
            present(error)
            return
        }
        
        let id = model.account.objectID
        let deserializedPublicKey = Data(hex: publicKey)
        let flags = model.account.flags
        let previousContract = model.account.selectedContract
        
        Task { @PersistenceWritableActor [weak self] in
            do {
                let initialCondition: Contract.InitialCondition
                switch kind {
                case .walletV1R1, .walletV1R2, .walletV1R3, .uninitialized:
                    throw ContractError.unknownContractType
                case .walletV2R1:
                    initialCondition = try await Wallet2.initial(revision: .r1, deserializedPublicKey: deserializedPublicKey)
                case .walletV2R2:
                    initialCondition = try await Wallet2.initial(revision: .r2, deserializedPublicKey: deserializedPublicKey)
                case .walletV3R1:
                    initialCondition = try await Wallet3.initial(revision: .r1, deserializedPublicKey: deserializedPublicKey)
                case .walletV3R2:
                    initialCondition = try await Wallet3.initial(revision: .r2, deserializedPublicKey: deserializedPublicKey)
                case .walletV4R1:
                    initialCondition = try await Wallet4.initial(revision: .r1, deserializedPublicKey: deserializedPublicKey)
                case .walletV4R2:
                    initialCondition = try await Wallet4.initial(revision: .r2, deserializedPublicKey: deserializedPublicKey)
                }
                
                guard let address = await Address(initial: initialCondition)
                else {
                    throw ContractError.unknownContractType
                }
                
                if flags.contains(.isNotificationsEnabled) {
                    let installationID = await InstallationIdentifier.shared.value
                    let unsubsribeRequest = AccountSettings.unsubscribeWalletTransactions(
                        installation_id: installationID.uuidString,
                        address: previousContract.address.rawValue
                    )
                    let subscribeRequest = AccountSettings.subscribeWalletTransactions(
                        installation_id: installationID.uuidString,
                        address: previousContract.address.rawValue
                    )
                    
                    let _ = try? await DefaultMOON.shared.do(unsubsribeRequest)
                    let _ = try? await DefaultMOON.shared.do(subscribeRequest)
                }
                
                let account = PersistenceAccount.writeableObject(id: id)
                
                try PersistencePendingTransaction.removeAll(for: account)
                try PersistenceProcessedTransaction.removeAll(for: account)
                
                account.balance = 0
                account.selectedContract = AccountContract(
                    address: address,
                    kind: kind
                )
                
                try account.save()
            } catch {
                await self?.present(error)
            }
            
            // Unwrap only when needed
            if let self = self {
                await self.delegate?.cardStackViewController(self, didChangeSelectedModel: model)
            }
        }
    }
    
    func showIsReadonlyViewController() {
        let viewController = AlertViewController(
            image: .image(
                .hui_info42,
                tintColor: .hui_letter_blue
            ),
            title: "ReadonlyAccountTitle".asLocalizedKey,
            message: "ReadonlyAccountMessage".asLocalizedKey,
            actions: [
                .done
            ]
        )
        
        hui_present(viewController, animated: true)
    }
    
    func removeAccount(_ model: CardStackCard) {
        let prompt: String
        if model.account.isReadonly {
            prompt = "AccountDeletePromptMessagePublic".asLocalizedKey
        } else {
            prompt = "AccountDeletePromptMessagePrivate".asLocalizedKey
        }

        let viewController = AlertViewController(
            image: .image(
                .hui_warning42,
                tintColor: .hui_letter_red
            ),
            title: "CommonAttention".asLocalizedKey,
            message: prompt,
            actions: [
                .init(
                    title: "AccountDeleteDestructiveButtonTitle".asLocalizedKey,
                    block: { viewController in
                        let id = model.account.objectID
                        Task { @PersistenceWritableActor in
                            let object = PersistenceAccount.writeableObject(id: id)
                            try? object.delete()
                        }
                        viewController.dismiss(animated: true)
                    },
                    style: .destructive
                ),
                .cancel
            ]
        )
        
        hui_present(
            viewController,
            animated: true
        )
    }
    
    func resynchronizeAccount(_ model: CardStackCard) {
        Task { @PersistenceWritableActor in
            try? PersistencePendingTransaction.removeAll(for: model.account)
            try? PersistenceProcessedTransaction.removeAll(for: model.account)
        }
    }
    
    func subscribePushNotifications(_ model: CardStackCard) {
        UIApplication.shared.requestNotificationsPermissionIfNeeded()

        let id = model.account.objectID
        let flags = model.account.flags
        let address = model.account.selectedContract.address

        Task { @PersistenceWritableActor in
            let installationID = await InstallationIdentifier.shared.value
            let request = AccountSettings.subscribeWalletTransactions(
                installation_id: installationID.uuidString,
                address: address.rawValue
            )

            do {
                let _ = try await DefaultMOON.shared.do(request)
            } catch {
                print(error)
                return
            }

            var mflags = flags
            mflags.insert(.isNotificationsEnabled)

            let object = PersistenceAccount.writeableObject(id: id)
            object.flags = mflags
            try? object.save()
        }
    }

    func unsubscribePushNotifications(_ model: CardStackCard) {
        let id = model.account.objectID
        let flags = model.account.flags
        let address = model.account.selectedContract.address

        Task { @PersistenceWritableActor in
            let installationID = await InstallationIdentifier.shared.value
            let request = AccountSettings.unsubscribeWalletTransactions(
                installation_id: installationID.uuidString,
                address: address.rawValue
            )

            do {
                let _ = try await DefaultMOON.shared.do(request)
            } catch {
                print(error)
                return
            }

            var mflags = flags
            mflags.remove(.isNotificationsEnabled)

            let object = PersistenceAccount.writeableObject(id: id)
            object.flags = mflags
            try? object.save()
        }
    }
    
    func changeAppearance(_ model: CardStackCard) {
        let viewController = AccountAppearenceViewController(
            initialConfiguration: .init(
                account: model.account
            )
        )

        hui_present(
            NavigationController(rootViewController: viewController),
            animated: true
        )
    }
    
    func backupAccount(_ model: CardStackCard) {
        guard let keyPublic = model.account.keyPublic,
              let keySecretEncrypted = model.account.keySecretEncrypted
        else {
            return
        }

        Task {
            let authentication = PasscodeAuthentication(inside: self)
            let passcode = try await authentication.key()

            let key = try Key(
                publicKey: keyPublic,
                encryptedSecretKey: Data(hex: keySecretEncrypted)
            )

            let words = try await key.words(password: passcode)

            let pasteboard = UIPasteboard.general
            pasteboard.string = words.joined(separator: " ")

            InAppAnnouncementCenter.shared.post(
                announcement: InAppAnnouncementInfo.self,
                with: .wordsCopied
            )
        }
    }
}

//
// MARK: NSFetchedResultsControllerDelegate
//

extension CardStackViewController: NSFetchedResultsControllerDelegate {
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let cards = { (_ snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>) in
            snapshot.itemIdentifiers.map({
                CardStackCard(account: PersistenceAccount.readableObject(id: $0))
            })
        }
        
        if let old = self.snapshot {
            // Update only if snapshot has an insetions or removals
            let previousIDs = old.itemIdentifiers.map({ $0.uriRepresentation() })
            let newIDs = snapshot.itemIdentifiers.map({ $0.uriRepresentation() })
            
            let difference = previousIDs.difference(from: newIDs)
            if !difference.insertions.isEmpty || !difference.removals.isEmpty {
                cardStackView.update(cards: cards(snapshot), animated: true)
            }
        } else {
            cardStackView.update(cards: cards(snapshot), animated: true)
        }
        
        self.snapshot = snapshot
    }
}

//
// MARK: CardStackViewDelegate
//

extension CardStackViewController: CardStackViewDelegate {

    func cardStackView(
        _ view: CardStackView,
        didChangeSelectedModel model: CardStackCard?,
        manually: Bool
    ) {
        if manually {
            Task { @PersistenceWritableActor in
                guard let id = model?.account.objectID
                else {
                    return
                }
                
                let object = PersistenceAccount.writeableObject(id: id)
                try? object.saveAsLastUsage()
            }
        }
        
        delegate?.cardStackViewController(self, didChangeSelectedModel: model)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickWhileModel model: CardStackCard
    ) {
        delegate?.cardStackViewController(
            self,
            didClickAtModel: model
        )
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickSendControl control: UIControl,
        model: CardStackCard
    ) {
        let viewController = TransferNavigationController(
            initialConfiguration: .init(
                fromAccount: model.account,
                toAddress: nil,
                amount: nil,
                message: nil
            )
        )
        
        hui_present(viewController, animated: true)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickReceiveControl control: UIControl,
        model: CardStackCard
    ) {
        let viewController = QRSharingViewController(
            initialConfiguration: .init(
                address: model.account.convienceSelectedAddress
            )
        )
        
        hui_present(
            NavigationController(rootViewController: viewController),
            animated: true
        )
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickTopupControl control: UIControl,
        model: CardStackCard
    ) {
        let viewController = TopupViewController()
        viewController.delegate = self
        
        hui_present(
            viewController,
            animated: true
        )
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickMoreControl control: UIControl,
        model: CardStackCard
    ) {
        guard let button = control as? UIButton
        else {
            return
        }
        
        var children: [UIMenuElement] = []
        
        // Remove
        children.append(UIAction(
            title: "CommonRemove".asLocalizedKey,
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                self?.removeAccount(model)
            }
        ))
        
        // Resynchronize
        children.append(UIAction(
            title: "AccountCardResynchronizeButton".asLocalizedKey,
            image: UIImage(systemName: "arrow.clockwise"),
            handler: { [weak self] _ in
                self?.resynchronizeAccount(model)
            }
        ))
        
//        // Subscribe/Unsubscribe
//        if model.account.flags.contains(.isNotificationsEnabled) {
//            children.append(UIAction(
//                title: "AccountCardUnsubscribeButton".asLocalizedKey,
//                image: UIImage(systemName: "bell.slash"),
//                handler: { [weak self] _ in
//                    self?.unsubscribePushNotifications(model)
//                }
//            ))
//        } else {
//            children.append(UIAction(
//                title: "AccountCardSubscribeButton".asLocalizedKey,
//                image: UIImage(systemName: "bell"),
//                handler: { [weak self] _ in
//                    self?.subscribePushNotifications(model)
//                }
//            ))
//        }
        
        // Appearance
        children.append(UIAction(
            title: "AccountCardChangeApperanceButton".asLocalizedKey,
            image: UIImage(systemName: "paintbrush"),
            handler: { [weak self] _ in
                self?.changeAppearance(model)
            }
        ))
        
        // Backup
        if !model.account.isReadonly {
            children.append(UIAction(
                title: "AccountCardBackupButton".asLocalizedKey,
                image: UIImage(systemName: "key"),
                handler: { [weak self] _ in
                    self?.backupAccount(model)
                }
            ))
        }
        
        button.sui_presentMenuIfPossible(
            UIMenu(children: children)
        )
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickReadonlyControl control: UIControl,
        model: CardStackCard
    ) {
        showIsReadonlyViewController()
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickVersionControl control: UIControl,
        model: CardStackCard
    ) {
        guard let button = control as? UIButton
        else {
            return
        }
        
        guard !model.account.isReadonly || model.account.keyPublic != nil
        else {
            showIsReadonlyViewController()
            return
        }
        
        var children: [UIMenuElement] = []
        let kinds: [Contract.Kind] = [
            .walletV2R1,
            .walletV2R2,
            .walletV3R1,
            .walletV3R2,
            .walletV4R1,
            .walletV4R2
        ]
        
        kinds.forEach({ kind in
            children.append(UIAction(
                title: kind.name,
                image: UIImage(systemName: "wallet.pass"),
                handler: { [weak self] _ in
                    self?.showSwitchAccount(
                        to: kind,
                        model: model
                    )
                }
            ))
        })

        button.sui_presentMenuIfPossible(
            UIMenu(children: children)
        )
    }
}

extension CardStackViewController: TopupViewControllerDelegate {
    
    func topupViewController(
        _ viewController: TopupViewControllerDelegate,
        didFinishWithError error: Error?
    ) {
        
    }
}
