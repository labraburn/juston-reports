//
//  Safari3WelcomeDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import JustonUI
import JustonCORE
import CoreData

protocol Safari3WelcomeDataSourceDelegate: AnyObject {
    
    func safari3WelcomeDataSource(
        _ dataSource: Safari3WelcomeDataSource,
        emptyStateButtonDidClick view: Safari3WelcomePlaceholderCollectionReusableView
    )
}

class Safari3WelcomeDataSource: CollectionViewDiffableDataSource<Safari3WelcomeDataSource.Section, Safari3WelcomeDataSource.Item> {

    enum Section {
        
        case initial
        case empty
        case banners
        case favourites
    }
    
    enum Item {
        
        case banner(id: NSManagedObjectID)
        case favourite(id: NSManagedObjectID)
    }
    
    weak var delegate: Safari3WelcomeDataSourceDelegate?
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        collectionView.register(reusableSupplementaryViewClass: Safari3WelcomePlaceholderCollectionReusableView.self)
        collectionView.register(reusableCellClass: Safari3BannerCollectionViewCell.self)
        collectionView.register(reusableCellClass: Safari3FavouriteCollectionViewCell.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .banner(id):
            let cell = collectionView.dequeue(
                reusableCellClass: Safari3BannerCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(banner: PersistenceBrowserBanner.readableObject(id: id))
            return cell
        case let .favourite(id):
            let cell = collectionView.dequeue(
                reusableCellClass: Safari3FavouriteCollectionViewCell.self,
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
        switch elementKind {
        case String(describing: Safari3WelcomePlaceholderCollectionReusableView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: Safari3WelcomePlaceholderCollectionReusableView.self,
                elementKind: elementKind,
                for: indexPath
            )
            view.action = { [weak self, weak view] in
                guard let self = self,
                      let view = view
                else {
                    return
                }

                self.delegate?.safari3WelcomeDataSource(
                    self,
                    emptyStateButtonDidClick: view
                )
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
        banners: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        favourites: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        _apply(
            banners: banners,
            favourites: favourites,
            animated: animated
        )
    }
    
    private func _apply(
        banners: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        favourites: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
        animated: Bool
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        if !banners.itemIdentifiers.isEmpty {
            banners.sectionIdentifiers.forEach({
                snapshot.appendSection(
                    .banners,
                    items: banners.itemIdentifiers(inSection: $0).map({ .banner(id: $0) })
                )
            })
        }
        
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

extension Safari3WelcomeDataSource.Item: Hashable {}

extension Safari3WelcomeDataSource.Section: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .initial:
            hasher.combine("initial")
        case .empty:
            hasher.combine("empty")
        case .banners:
            hasher.combine("banners")
        case .favourites:
            hasher.combine("favourites")
        }
    }
}

extension Safari3BannerCollectionViewCell.Model {
    
    init(
        banner: PersistenceBrowserBanner
    ) {
        self.title = banner.title
        self.subtitle = banner.subtitle
        self.imageURL = banner.imageURL
    }
}

extension Safari3FavouriteCollectionViewCell.Model {
    
    init(
        favourite: PersistenceBrowserFavourite
    ) {
        self.title = favourite.title
        self.url = favourite.url
    }
}
