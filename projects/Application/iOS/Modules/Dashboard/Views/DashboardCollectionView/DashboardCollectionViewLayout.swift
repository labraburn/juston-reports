//
//  DashboardCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI

class DashboardCollectionViewLayout: CollectionViewCompositionalLayout {
    
    override init() {
        super.init()
        refreshLayoutConfiguration(pinToVisibleBounds: false)
    }

    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        
        guard let section = DashboardDiffableDataSource.Section(rawValue: index)
        else {
            fatalError("Can't identifiy DashboardCollectionViewLayout with index: \(index)")
        }

        switch section {
        case .transactions:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(DashboardTransactionCollectionViewCell.absoluteHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 32,
                leading: 12,
                bottom: 12,
                trailing: 12
            )

            return section
        }
    }
    
    func refreshLayoutConfiguration(pinToVisibleBounds: Bool) {
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)),
            elementKind: String(describing: DashboardCollectionHeaderView.self),
            alignment: .top
        )
        
        item.pinToVisibleBounds = pinToVisibleBounds
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        configuration.boundarySupplementaryItems = [item]
        
        self.configuration = configuration
    }
}
