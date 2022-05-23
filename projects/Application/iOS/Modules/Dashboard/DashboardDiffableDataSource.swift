//
//  DashboardDiffableDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

protocol DashboardDiffableDataSourceDelegate: AnyObject {
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        layoutTypeForCollectionHeaderView view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderView.LayoutType
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        subviewForCollectionHeaderView view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderSubview
}

class DashboardDiffableDataSource: CollectionViewDiffableDataSource<DashboardDiffableDataSource.Section, DashboardDiffableDataSource.Item> {

    enum Section {
        
        case pendingTransactions
        case processedTransactions(dateString: String)
    }
    
    enum Item: Hashable {
        
        case pendingTransaction(id: NSManagedObjectID)
        case processedTransaction(id: NSManagedObjectID)
    }
    
    weak var delegate: DashboardDiffableDataSourceDelegate?
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        collectionView.register(reusableSupplementaryViewClass: DashboardDateReusableView.self)
        collectionView.register(reusableCellClass: DashboardTransactionCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .pendingTransaction(id):
            let cell = collectionView.dequeue(
                reusableCellClass: DashboardTransactionCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(transaction: PersistencePendingTransaction.readableObject(id: id))
            return cell
        case let .processedTransaction(id):
            let cell = collectionView.dequeue(
                reusableCellClass: DashboardTransactionCollectionViewCell.self,
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
        case String(describing: DashboardCollectionHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: DashboardCollectionHeaderView.self,
                elementKind: elementKind,
                for: indexPath
            )
            
            view.delegate = self
            view.subview = delegate?.dashboardDiffableDataSource(
                self,
                subviewForCollectionHeaderView: view
            )
            
            return view
        case String(describing: DashboardDateReusableView.self):
            guard let sectionIdentifier = sectionIdentifier(forSectionIndex: indexPath.section)
            else {
                fatalError("[DashboardDiffableDataSource] - Can't idetify section for \(indexPath)")
            }
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: DashboardDateReusableView.self,
                elementKind: elementKind,
                for: indexPath
            )
            switch sectionIdentifier {
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
    
    func apply(
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
}

extension DashboardDiffableDataSource: DashboardCollectionHeaderViewDelegate {
    
    func dashboardCollectionHeaderViewLayoutType(
        for view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderView.LayoutType {
        guard let delegate = delegate
        else {
            return .init(bounds: .zero, safeAreaInsets: .zero, kind: .compact)
        }
        
        return delegate.dashboardDiffableDataSource(self, layoutTypeForCollectionHeaderView: view)
    }
}

extension DashboardDiffableDataSource.Section: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .pendingTransactions:
            hasher.combine("pending_transactions")
        case let .processedTransactions(dateString):
            hasher.combine("processed_transactions_\(dateString)")
        }
    }
}

extension DashboardTransactionCollectionViewCell.Model {
    
    init(transaction: PersistencePendingTransaction) {
        from = transaction.account.selectedAddress
        to = [transaction.destinationAddress]
        
        kind = .pending
        value = transaction.value
    }
    
    init(transaction: PersistenceProcessedTransaction) {
        if !transaction.out.isEmpty {
            from = transaction.account.selectedAddress
            to = transaction.out.compactMap({ $0.destinationAddress })
            
            kind = .out
            value = transaction.out.reduce(into: Currency(value: 0), { $0 += $1.value })
        } else if let action = transaction.in {
            from = transaction.account.selectedAddress
            to = [action].compactMap({ $0.destinationAddress })
            
            kind = .in
            value = action.value
        } else {
            // Possible just deploying or SMC run
            from = transaction.account.selectedAddress
            to = [transaction.account.selectedAddress]
            
            kind = .out
            value = Currency(value: 0)
        }
    }
}
