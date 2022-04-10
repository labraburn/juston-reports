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
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18)
            return section
        case .words:
            let width = withEnvironmant.container.contentSize.width
            let iwidth = (width - 68) / 2 - 1 // 1 it's truth
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(iwidth), heightDimension: .estimated(1))
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)),
                subitems: [item, item]
            )
            group.interItemSpacing = .flexible(8)
            
            let decorationItem = NSCollectionLayoutDecorationItem.background(
                elementKind: String(describing: SteppableWordsDecorationView.self)
            )
            
            decorationItem.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 18,
                bottom: 12,
                trailing: 18
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.decorationItems = [decorationItem]
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 30, bottom: 24, trailing: 30)
            return section
        }
    }
}
