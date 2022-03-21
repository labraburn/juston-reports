//
//  AccountAddingViewCollectionViewLayout.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import BilftUI

protocol AccountAddingViewCollectionViewLayoutDelegate: AnyObject {
    
    func accountAddingViewCollectionViewLayout(
        _ layout: AccountAddingViewCollectionViewLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> AccountAddingSection?
}

class AccountAddingViewCollectionViewLayout: CollectionViewCompositionalLayout {
    
    weak var delegate: AccountAddingViewCollectionViewLayoutDelegate?
    
    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard let sectionIdentifier = delegate?.accountAddingViewCollectionViewLayout(self, sectionIdentifierFor: index)
        else {
            return nil
        }
        
        switch sectionIdentifier {
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
                elementKind: String(describing: AccountAddingWordsDecorationView.self)
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
