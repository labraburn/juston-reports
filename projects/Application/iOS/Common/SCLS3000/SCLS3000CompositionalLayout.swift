//
//  SCLS3000CompositionalLayout.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

protocol SCLS3000CompositionalLayoutDelegate: AnyObject {
    
    func collectionViewLayout(
        _ layout: SCLS3000CompositionalLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> SCLS3000Section?
    
    func collectionViewLayout(
        _ layout: SCLS3000CompositionalLayout,
        numberOfItemsInSection sectionIndex: Int
    ) -> Int
}

class SCLS3000CompositionalLayout: CollectionViewCompositionalLayout {

    weak var delegate: SCLS3000CompositionalLayoutDelegate?
    
    override init() {
        super.init()
        register(reusableDecorationViewOfKind: SCLS3000ListGroupDecorationView.self)
    }
    
    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard let sectionIdentifier = delegate?.collectionViewLayout(self, sectionIdentifierFor: index)
        else {
            return .zero
        }
        
        let numberOfItems = delegate?.collectionViewLayout(self, numberOfItemsInSection: index) ?? 0
        
        var headerHeightOffset: CGFloat = 0
        var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
        
        switch sectionIdentifier.header {
        case .none:
            break
        case .title:
            headerHeightOffset += 14
            let boundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(14)),
                elementKind: String(describing: SCLS3000ListGroupHeaderView.self),
                alignment: .top
            )
            boundarySupplementaryItems.append(boundarySupplementaryItem)
        case .logo:
            headerHeightOffset += 48
            let boundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(48)),
                elementKind: String(describing: SCLS3000LogoHeaderView.self),
                alignment: .top
            )
            boundarySupplementaryItems.append(boundarySupplementaryItem)
        case .applicationVersion:
            headerHeightOffset += 38
            let boundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(38)),
                elementKind: String(describing: SCLS3000ApplicationVersionHeaderView.self),
                alignment: .top
            )
            boundarySupplementaryItems.append(boundarySupplementaryItem)
        }
        
        
        switch sectionIdentifier.kind {
        case .list:
            var decorationItems: [NSCollectionLayoutDecorationItem] = []
            if numberOfItems > 0 {
                let decorationItem = NSCollectionLayoutDecorationItem.background(
                    elementKind: String(describing: SCLS3000ListGroupDecorationView.self)
                )
                decorationItem.contentInsets = NSDirectionalEdgeInsets(top: headerHeightOffset + 6, leading: 8, bottom: 18, trailing: 8)
                decorationItems.append(decorationItem)
            }
            
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(24)
            )
                                              
            let item = NSCollectionLayoutItem(
                layoutSize: size
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: size,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.boundarySupplementaryItems = boundarySupplementaryItems
            section.decorationItems = decorationItems
            
            if numberOfItems > 0 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 24, bottom: 30, trailing: 24)
            } else {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            }
            
            return section
        case .simple:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(42)
            )
                                              
            let item = NSCollectionLayoutItem(
                layoutSize: size
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: size,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.boundarySupplementaryItems = boundarySupplementaryItems
            
            if numberOfItems > 0 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 24, trailing: 12)
            } else {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            }
            
            return section
        }
    }
}
