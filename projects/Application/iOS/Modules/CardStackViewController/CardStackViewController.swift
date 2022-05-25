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
//                        try? model.account.delete()
//                        viewController.dismiss(animated: true)
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

        let id = model.account.objectID
        let flags = model.account.flags
        
        Task { @PersistenceWritableActor in
            var mflags = flags
            mflags.insert(.isNotificationsEnabled)
            
            let object = PersistenceAccount.writeableObject(id: id)
            object.flags = mflags
            try? object.save()
        }
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickUnsubscrabeButtonWithModel model: CardStackCard
    ) {
        let id = model.account.objectID
        let flags = model.account.flags
        
        Task { @PersistenceWritableActor in
            var mflags = flags
            mflags.remove(.isNotificationsEnabled)
            
            let object = PersistenceAccount.writeableObject(id: id)
            object.flags = mflags
            try? object.save()
        }
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickResynchronizeButtonWithModel model: CardStackCard
    ) {
        Task { @PersistenceWritableActor in
            try? PersistencePendingTransaction.removeAll(for: model.account)
            try? PersistenceProcessedTransaction.removeAll(for: model.account)
        }
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickSendButtonWithModel model: CardStackCard
    ) {
        guard let key = model.account.keyIfAvailable
        else {
            return
        }
        
        let viewController = TransferNavigationController(
            initialConfiguration: .init(
                fromAccount: model.account,
                toAddress: nil,
                key: key,
                amount: nil,
                message: nil
            )
        )
        
        hui_present(viewController, animated: true)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickReceiveButtonWithModel model: CardStackCard
    ) {
        let viewController = QRSharingViewController(
            initialConfiguration: .init(
                address: model.account.selectedAddress
            )
        )
        
        let navigationController = NavigationController(rootViewController: viewController)
        hui_present(navigationController, animated: true)
    }
    
    func cardStackView(
        _ view: CardStackView,
        didClickWhileModel model: CardStackCard
    ) {
        delegate?.cardStackViewController(self, didClickAtModel: model)
    }
}
