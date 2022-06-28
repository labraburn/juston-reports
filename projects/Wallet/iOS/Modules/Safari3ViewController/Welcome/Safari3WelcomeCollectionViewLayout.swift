//
//  Safari3WelcomeCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import HuetonUI

protocol Safari3WelcomeCollectionViewLayoutDelegate: AnyObject {
    
    func safari3WelcomeCollectionViewSectionForIndex(
        index: Int
    ) -> Safari3WelcomeDataSource.Section?
}

class Safari3WelcomeCollectionViewLayout: CollectionViewCompositionalLayout {
    
    weak var delegate: Safari3WelcomeCollectionViewLayoutDelegate?
    
    override init() {
        super.init()
        refreshLayoutConfiguration(pinToVisibleBounds: false)
    }

    override func section(
        forIndex index: Int,
        withEnvironmant environmnet: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        
        guard let section = delegate?.safari3WelcomeCollectionViewSectionForIndex(index: index)
        else {
            fatalError("[TransactionsCollectionViewLayout]: Can't identifiy index: \(index)")
        }
        
        let leadingTrailingPadding = CGFloat(18)

        switch section {
        case .initial:
            return .zero
        case .empty:
            let placeholderItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Safari3WelcomePlaceholderCollectionReusableView.estimatedHeight)),
                elementKind: String(describing: Safari3WelcomePlaceholderCollectionReusableView.self),
                alignment: .top
            )
            placeholderItem.zIndex = -1
            
            let section: NSCollectionLayoutSection = .zero
            section.boundarySupplementaryItems = [
                placeholderItem
            ]
            
            return section
        case .banners:
            let width = environmnet.container.contentSize.width

            let item = NSCollectionLayoutItem(
                layoutSize: .parent
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth((width - leadingTrailingPadding * 2) / width),
                    heightDimension: .absolute(Safari3BannerCollectionViewCell.absoluteHeight)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: leadingTrailingPadding,
                bottom: 0,
                trailing: leadingTrailingPadding
            )

            return section
        case .favourites:
            let spacing = CGFloat(12)
            
            let contentWidth = environmnet.container.contentSize.width
            let elementWidth = (contentWidth - spacing * 3) / 4
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(elementWidth),
                    heightDimension: .estimated(elementWidth)
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(elementWidth)
                ),
                subitem: item,
                count: 4
            )
            
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.supplementariesFollowContentInsets = true
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: leadingTrailingPadding,
                bottom: 16,
                trailing: leadingTrailingPadding
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
