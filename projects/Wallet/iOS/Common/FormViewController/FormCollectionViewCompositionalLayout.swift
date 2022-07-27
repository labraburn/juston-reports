//
//  FormCollectionViewCompositionalLayout.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI

protocol FormCollectionViewCompositionalLayoutDelegate: AnyObject {
    
    func collectionViewLayout(
        _ layout: FormCollectionViewCompositionalLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> FormCollectionViewSection?
}

class FormCollectionViewCompositionalLayout: CollectionViewCompositionalLayout {

    weak var delegate: FormCollectionViewCompositionalLayoutDelegate?
    
    override func section(
        forIndex index: Int,
        withEnvironmant: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard let sectionIdentifier = delegate?.collectionViewLayout(self, sectionIdentifierFor: index)
        else {
            return .zero
        }
        
        switch sectionIdentifier {
        case .simple:
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(10)
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
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 24, trailing: 12)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)),
                    elementKind: String(describing: FormButtonsCollectionReusableView.self),
                    alignment: .bottom
                )
            ]

            return section
        }
    }
}
