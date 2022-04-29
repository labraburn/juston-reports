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
        presentUnderDevelopment()
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
