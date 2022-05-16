//
//  CardStackViewController.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonCORE
import CoreData

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
                CardStackCard(account: PersistenceObject.object(with: $0, type: PersistenceAccount.self))
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
            try? model?.account.saveAsLastUsage()
        }
        
        delegate?.cardStackViewController(self, didChangeSelectedModel: model)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickRemoveButtonWithModel model: CardStackCard
    ) {
        let viewController = AlertViewController(
            image: .image(.hui_warning42, tintColor: .hui_letter_red),
            title: "CommonAttention".asLocalizedKey,
            message: "AccountDeletePromptMessage".asLocalizedKey,
            actions: [
                .init(
                    title: "AccountDeleteDestructiveTitle".asLocalizedKey,
                    block: { viewController in
                        try? model.account.delete()
                        viewController.dismiss(animated: true)
                    },
                    style: .destructive
                ),
                .cancel
            ]
        )
        present(viewController, animated: true)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickSubscribeButtonWithModel model: CardStackCard
    ) {
        UIApplication.shared.requestNotificationsPermissionIfNeeded()

        var subscriptions = model.account.subscriptions
        subscriptions.append(.transactions)

        model.account.subscriptions = subscriptions
        try? model.account.save()
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickUnsubscrabeButtonWithModel model: CardStackCard
    ) {
        var subscriptions = model.account.subscriptions
        subscriptions.removeAll(where: { $0 == .transactions })

        model.account.subscriptions = subscriptions
        try? model.account.save()
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickSendButtonWithModel model: CardStackCard
    ) {
        guard let publicKey = model.account.keyPublic,
              let encryptedSecretKey = model.account.keySecretEncrypted
        else {
            return
        }
        
        let viewController = TransferViewController(
            initialConfiguration: .init(
                fromAddress: model.account.selectedAddress,
                toAddress: nil,
                key: .init(publicKey: publicKey, encryptedSecretKey: Data(hex: encryptedSecretKey)),
                amount: nil,
                message: nil)
        )
        
        present(viewController, animated: true)
//        presentUnderDevelopment()
        
        
        
        guard task == nil
        else {
            print("in progress")
            return
        }
        
//        Task { [weak self] in
//
//            do {
//
//                let account = model.account
//
//                guard let self = self,
//                      let publicKey = account.keyPublic,
//                      let encryptedSecretKey = account.keySecretEncrypted
//                else {
//                    throw SwiftyTON.Error.undefined
//                }
//
//                let authentication = PasscodeAuthentication(inside: self)
//                let passcode = try await authentication.key()
//                let key = Key(publicKey: publicKey, encryptedSecretKey: Data(hex: encryptedSecretKey))
//
//                var message = try await Wallet3.deploy(key: key, passcode: passcode)
//                try await message.prepare()
//
//                let fees = try await message.fees()
//                print("Deployment fees: \(fees)")
//
//                try await message.send()
//            } catch {
//                print(error)
//            }
//
//            self?.task = nil
//        }
        
//        Task { [weak self] in
//            
//            do {
//                
//                let account = model.account
//                
//                guard let self = self,
//                      let publicKey = account.keyPublic,
//                      let encryptedSecretKey = account.keySecretEncrypted
//                else {
//                    throw SwiftyTON.Error.undefined
//                }
//                
//                let authentication = PasscodeAuthentication(inside: self)
//                let passcode = try await authentication.key()
//                let key = Key(publicKey: publicKey, encryptedSecretKey: Data(hex: encryptedSecretKey))
//                
//                guard let wallet = try await Wallet3(rawAddress: account.selectedAddress.rawValue)
//                else {
//                    throw SwiftyTON.Error.undefined
//                }
//                
//                var message = try await wallet.transfer(
//                    to: try Address(base64EncodedString: "UQDg9_pJnr1wjmLjIQJF9dLVhzX_C_JDF5YF1T52HxvITaOS"),
//                    amount: Balance(value: 0.001),
//                    message: "HUETON",
//                    key: key,
//                    passcode: passcode
//                )
//                
//                try await message.prepare()
//                
//                let fees = try await message.fees()
//                print("Sending fees: \(fees)")
//                
//                try await message.send()
//            } catch {
//                print(error)
//            }
//            
//            self?.task = nil
//        }
        
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickReceiveButtonWithModel model: CardStackCard
    ) {
        presentUnderDevelopment()
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickWhileModel model: CardStackCard
    ) {
        delegate?.cardStackViewController(self, didClickAtModel: model)
    }
}
