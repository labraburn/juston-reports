//
//  DashboardDiffableDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import BilftUI
import SwiftyTON

class DashboardDiffableDataSource: CollectionViewDiffableDataSource<DashboardDiffableDataSource.Section, DashboardDiffableDataSource.Item> {

    enum Section: Int {
        
        case wallets
        case transactions
    }
    
    enum Item: Hashable {
        
        case wallet(valaue: Wallet)
        case transaction(value: Int)
    }
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: DashboardWalletCollectionViewCell.self)
        collectionView.register(reusableCellClass: DashboardTransactionCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .wallet(value):
            let cell = collectionView.dequeue(
                reusableCellClass: DashboardWalletCollectionViewCell.self,
                for: indexPath
            )
            cell.fill(with: value)
            return cell
        case .transaction:
            let cell = collectionView.dequeue(
                reusableCellClass: DashboardTransactionCollectionViewCell.self,
                for: indexPath
            )
            return cell
        }
    }
    
    func apply(_ wallet: Wallet, animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.wallets, .transactions])
        snapshot.appendItems([.wallet(valaue: wallet)], toSection: .wallets)
        snapshot.appendItems([
            .transaction(value: 0),
        ], toSection: .transactions)
        apply(snapshot, animatingDifferences: animated)
    }
}
