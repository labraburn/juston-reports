//
//  Safari3SearchDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

class Safari3SearchDataSource: CollectionViewDiffableDataSource<Safari3SearchDataSource.Section, Safari3SearchDataSource.Item> {

    enum Section {
        
        case initial
        case empty
        case favourites
    }
    
    enum Item {
        
        case favourite(id: NSManagedObjectID)
    }
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        collectionView.register(reusableSupplementaryViewClass: Safari3SearchPlaceholderCollectionReusableView.self)
        collectionView.register(reusableCellClass: Safari3SearchCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .favourite(id):
            let cell = collectionView.dequeue(
                reusableCellClass: Safari3SearchCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(favourite: PersistenceBrowserFavourite.readableObject(id: id))
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
    
        switch elementKind {
        case String(describing: Safari3SearchPlaceholderCollectionReusableView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: Safari3SearchPlaceholderCollectionReusableView.self,
                elementKind: elementKind,
                for: indexPath
            )
            
            switch section {
            case .empty:
                view.text = "Safari3SearchEmpty".asLocalizedKey
            case .initial:
                view.text = "Safari3SearchPlaceholder".asLocalizedKey
            case .favourites:
                break
            }
            
            return view
        default:
            return nil
        }
    }
    
    func applyInitial() {
        _applyInitial()
    }
    
    func apply(
        favourites: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        _apply(
            favourites: favourites,
            animated: animated
        )
    }
    
    private func _apply(
        favourites: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        if favourites.itemIdentifiers.isEmpty {
            snapshot.appendSection(
                .empty,
                items: []
            )
        } else {
            favourites.sectionIdentifiers.forEach({
                snapshot.appendSection(
                    .favourites,
                    items: favourites.itemIdentifiers(inSection: $0).map({ .favourite(id: $0) })
                )
            })
        }
        
        apply(snapshot, animatingDifferences: animated)
    }
    
    private func _applyInitial() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.initial])
        apply(snapshot, animatingDifferences: false)
    }
}

extension Safari3SearchDataSource.Item: Hashable {}

extension Safari3SearchDataSource.Section: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .initial:
            hasher.combine("initial")
        case .empty:
            hasher.combine("empty")
        case .favourites:
            hasher.combine("favourites")
        }
    }
}

extension Safari3SearchCollectionViewCell.Model {
    
    init(
        favourite: PersistenceBrowserFavourite
    ) {
        self.title = favourite.title
        self.url = favourite.url
    }
}
