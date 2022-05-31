//
//  SteppableViewCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonUI

protocol SteppableViewCollectionViewLayoutDelegate: AnyObject {
    
    func steppableViewCollectionViewLayout(
        _ layout: SteppableViewCollectionViewLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> SteppableSection?
}

class SteppableViewCollectionViewLayout: CollectionViewCompositionalLayout {
    
    weak var delegate: SteppableViewCollectionViewLayoutDelegate?
    
    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard let sectionIdentifier = delegate?.steppableViewCollectionViewLayout(self, sectionIdentifierFor: index)
        else {
            return nil
        }
        
        switch sectionIdentifier.kind {
        case .simple:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 18, trailing: 18)
            return section
        case .words:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .estimated(1))
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)),
                subitems: [item, item, item]
            )
            group.interItemSpacing = .fixed(12)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 18, trailing: 18)
            return section
        }
    }
}
