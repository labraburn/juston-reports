//
//  DashboardCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import BilftUI

class DashboardCollectionViewLayout: CollectionViewCompositionalLayout {

    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        
        guard let section = DashboardDiffableDataSource.Section(rawValue: index)
        else {
            fatalError("Can't identifiy DashboardCollectionViewLayout with index: \(index)")
        }

        switch section {
        case .wallets:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(DashboardWalletCollectionViewCell.absoluteHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: size)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 12,
                bottom: 0,
                trailing: 12
            )

//            let footer = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1),
//                    heightDimension: .estimated(S.Sizes.minButtonHeight)
//                ),
//                elementKind: String(describing: PageControlFooterView.self),
//                alignment: .bottom
//            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
//            section.boundarySupplementaryItems = [footer]
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 0,
                bottom: 0,
                trailing: 0
            )

            return section
        case .transactions:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(DashboardTransactionCollectionViewCell.absoluteHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 12,
                bottom: 12,
                trailing: 12
            )

            return section
        }
    }
}
