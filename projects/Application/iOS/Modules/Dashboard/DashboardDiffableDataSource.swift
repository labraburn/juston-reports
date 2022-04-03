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

    enum Section: Int {
        
        case transactions
    }
    
    enum Item: Hashable {
        
        case transaction(value: NSManagedObjectID)
    }
    
    weak var delegate: DashboardDiffableDataSourceDelegate?
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        collectionView.register(reusableCellClass: DashboardTransactionCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .transaction(value):
            let cell = collectionView.dequeue(
                reusableCellClass: DashboardTransactionCollectionViewCell.self,
                for: indexPath
            )
            cell.model = PersistenceObject.object(with: value, type: PersistenceTransaction.self)
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
        default:
            return nil
        }
    }
    
    func apply(transactions: [NSManagedObjectID], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.transactions])
        snapshot.appendItems(transactions.map({ .transaction(value: $0) }), toSection: .transactions)
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
