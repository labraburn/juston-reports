//
//  TransactionsCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI

protocol TransactionsCollectionViewLayoutDelegate: AnyObject {
    
    func transactionsCollectionViewLayoutSectionForIndex(
        index: Int
    ) -> TransactionsDiffableDataSource.Section?
}

class TransactionsCollectionViewLayout: CollectionViewCompositionalLayout {
    
    weak var delegate: TransactionsCollectionViewLayoutDelegate?
    
    override init() {
        super.init()
        refreshLayoutConfiguration(pinToVisibleBounds: false)
    }

    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        
        guard let section = delegate?.transactionsCollectionViewLayoutSectionForIndex(index: index)
        else {
            fatalError("Can't identifiy TransactionsCollectionViewLayout with index: \(index)")
        }

        switch section {
        case .initial:
            return .zero
        case .empty:
            let placeholderItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(TransactionsPlaceholderCollectionReusableView.estimatedHeight)
                ),
                elementKind: String(describing: TransactionsPlaceholderCollectionReusableView.self),
                alignment: .top
            )
            placeholderItem.zIndex = -1
            
            let section: NSCollectionLayoutSection = .zero
            section.boundarySupplementaryItems = [
                placeholderItem
            ]
            return section
        case .pendingTransactions, .processedTransactions:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(TransactionsTransactionCollectionViewCell.absoluteHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

            let dateItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(TransactionsDateReusableView.estimatedHeight)),
                elementKind: String(describing: TransactionsDateReusableView.self),
                alignment: .top
            )
            dateItem.zIndex = -1
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.supplementariesFollowContentInsets = true
            section.boundarySupplementaryItems = [
                dateItem
            ]
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 12,
                bottom: 16,
                trailing: 12
            )

            return section
        }
    }
    
    func refreshLayoutConfiguration(pinToVisibleBounds: Bool) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        self.configuration = configuration
    }
}
