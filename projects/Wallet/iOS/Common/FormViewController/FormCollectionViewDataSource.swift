//
//  FormCollectionViewDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI

enum FormCollectionViewSection {
    
    case simple(models: [FormButtonsCollectionReusableView.Model])
}

enum FormCollectionViewItem {
    
    case input(model: FormInputCollectionViewCell.Model)
    case text(model: FormTextCollectionViewCell.Model)
}

class FormCollectionViewDataSource: CollectionViewDiffableDataSource<FormCollectionViewSection, FormCollectionViewItem> {
    
    weak var formInputCellDelegate: FormInputCollectionViewCellDelegate?

    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: FormInputCollectionViewCell.self)
        collectionView.register(reusableCellClass: FormTextCollectionViewCell.self)
        
        collectionView.register(reusableSupplementaryViewClass: FormButtonsCollectionReusableView.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: FormCollectionViewItem
    ) -> UICollectionViewCell? {
        switch item {
        case let .input(model):
            let cell = collectionView.dequeue(reusableCellClass: FormInputCollectionViewCell.self, for: indexPath)
            cell.model = model
            cell.delegate = formInputCellDelegate
            return cell
        case let .text(model):
            let cell = collectionView.dequeue(reusableCellClass: FormTextCollectionViewCell.self, for: indexPath)
            cell.model = model
            return cell
        }
    }
    
    override func view(
        with collectionView: UICollectionView,
        elementKind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard let section = sectionIdentifier(forSectionIndex: indexPath.section)
        else {
            return nil
        }
        
        switch (section, elementKind) {
        case (.simple(let models), String(describing: FormButtonsCollectionReusableView.self)):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: FormButtonsCollectionReusableView.self,
                for: indexPath
            )
            view.models = models
            return view
        default:
            return nil
        }
    }
}

extension FormCollectionViewSection: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .simple:
            hasher.combine("simple")
        }
    }
}

extension FormCollectionViewSection: Equatable {
    
    static func == (lhs: FormCollectionViewSection, rhs: FormCollectionViewSection) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension FormCollectionViewItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .input(model):
            hasher.combine(model.placeholder)
            hasher.combine(model.text ?? "")
        case let .text(model):
            hasher.combine(model.text)
        }
    }
}

extension FormCollectionViewItem: Equatable {
    
    static func == (lhs: FormCollectionViewItem, rhs: FormCollectionViewItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
