//
//  TransactionsDiffableDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

protocol TransactionsDiffableDataSourceDelegate: AnyObject {
    
    func transactionsDiffableDataSource(
        _ dataSource: TransactionsDiffableDataSource,
        emptyStateButtonDidClick view: TransactionsPlaceholderCollectionReusableView
    )
}

class TransactionsDiffableDataSource: CollectionViewDiffableDataSource<TransactionsDiffableDataSource.Section, TransactionsDiffableDataSource.Item> {

    enum Section {
        
        case initial
        case empty
        case pendingTransactions
        case processedTransactions(dateString: String)
    }
    
    enum Item: Hashable {
        
        case pendingTransaction(id: NSManagedObjectID)
        case processedTransaction(id: NSManagedObjectID)
    }
    
    weak var delegate: TransactionsDiffableDataSourceDelegate?
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        collectionView.register(reusableSupplementaryViewClass: TransactionsDateReusableView.self)
        collectionView.register(reusableSupplementaryViewClass: TransactionsPlaceholderCollectionReusableView.self)
        collectionView.register(reusableCellClass: TransactionsTransactionCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .pendingTransaction(id):
            let cell = collectionView.dequeue(
                reusableCellClass: TransactionsTransactionCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(transaction: PersistencePendingTransaction.readableObject(id: id))
            return cell
        case let .processedTransaction(id):
            let cell = collectionView.dequeue(
                reusableCellClass: TransactionsTransactionCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(transaction: PersistenceProcessedTransaction.readableObject(id: id))
            return cell
        }
    }
    
    override func view(
        with collectionView: UICollectionView,
        elementKind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        switch elementKind {
        case String(describing: TransactionsPlaceholderCollectionReusableView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: TransactionsPlaceholderCollectionReusableView.self,
                elementKind: elementKind,
                for: indexPath
            )
            view.action = { [weak self, weak view] in
                guard let self = self,
                      let view = view
                else {
                    return
                }
                
                self.delegate?.transactionsDiffableDataSource(
                    self,
                    emptyStateButtonDidClick: view
                )
            }
            return view
        case String(describing: TransactionsDateReusableView.self):
            guard let sectionIdentifier = sectionIdentifier(forSectionIndex: indexPath.section)
            else {
                fatalError("[TransactionsDiffableDataSource] - Can't idetify section for \(indexPath)")
            }
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: TransactionsDateReusableView.self,
                elementKind: elementKind,
                for: indexPath
            )
            switch sectionIdentifier {
            case .empty, .initial:
                view.model = ""
            case .pendingTransactions:
                view.model = "Pending"
            case let .processedTransactions(dateString):
                view.model = dateString
            }
            return view
        default:
            return nil
        }
    }
    
    func applyInitial() {
        _applyInitial()
    }
    
    func apply(
        pendingTransactions: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        processedTransactions: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        if pendingTransactions.numberOfItems == 0 && processedTransactions.numberOfItems == 0 {
            _apply(
                emptyDataSourceAnimated: animated
            )
        } else {
            _apply(
                pendingTransactions: pendingTransactions,
                processedTransactions: processedTransactions,
                animated: animated
            )
        }
    }
    
    private func _apply(
        emptyDataSourceAnimated animated: Bool
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.empty])
        apply(snapshot, animatingDifferences: animated)
    }
    
    private func _apply(
        pendingTransactions: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        processedTransactions: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if !pendingTransactions.itemIdentifiers.isEmpty {
            pendingTransactions.sectionIdentifiers.forEach({
                snapshot.appendSection(
                    .pendingTransactions,
                    items: pendingTransactions.itemIdentifiers(inSection: $0).map({ .pendingTransaction(id: $0) })
                )
            })
        }
        if !processedTransactions.itemIdentifiers.isEmpty {
            processedTransactions.sectionIdentifiers.forEach({
                snapshot.appendSection(
                    .processedTransactions(dateString: $0),
                    items: processedTransactions.itemIdentifiers(inSection: $0).map({ .processedTransaction(id: $0) })
                )
            })
        }
        apply(snapshot, animatingDifferences: animated)
    }
    
    private func _applyInitial() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.initial])
        apply(snapshot, animatingDifferences: false)
    }
}

extension TransactionsDiffableDataSource.Section: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .initial:
            hasher.combine("initial")
        case .empty:
            hasher.combine("empty")
        case .pendingTransactions:
            hasher.combine("pending_transactions")
        case let .processedTransactions(dateString):
            hasher.combine("processed_transactions_\(dateString)")
        }
    }
}

extension TransactionsTransactionCollectionViewCell.Model {
    
    init(transaction: PersistencePendingTransaction) {
        from = Address(rawValue: transaction.account.selectedContract.address)
        to = [transaction.destinationAddress]
        
        kind = .pending
        value = transaction.value
    }
    
    init(transaction: PersistenceProcessedTransaction) {
        if !transaction.out.isEmpty {
            from = Address(rawValue: transaction.account.selectedContract.address)
            to = transaction.out.compactMap({ $0.destinationAddress })
            
            kind = .out
            value = transaction.out.reduce(into: Currency(value: 0), { $0 += $1.value })
        } else if let action = transaction.in {
            from = Address(rawValue: transaction.account.selectedContract.address)
            to = [action].compactMap({ $0.destinationAddress })
            
            kind = .in
            value = action.value
        } else {
            // Possible just deploying or SMC run
            from = Address(rawValue: transaction.account.selectedContract.address)
            to = [Address(rawValue: transaction.account.selectedContract.address)]
            
            kind = .out
            value = Currency(value: 0)
        }
    }
}
