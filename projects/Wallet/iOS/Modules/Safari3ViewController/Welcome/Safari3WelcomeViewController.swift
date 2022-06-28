//
//  Safari3WelcomeViewController.swift
//  iOS
//
//  Created by Anton Spivak on 25.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

protocol Safari3WelcomeViewControllerDelegate: AnyObject {
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickBrowserFavourite favourite: PersistenceBrowserFavourite
    )
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickBrowserBanner banner: PersistenceBrowserBanner
    )
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickFavouritesEmptyView view: Safari3WelcomePlaceholderCollectionReusableView
    )
}

class Safari3WelcomeViewController: UIViewController {
    
    private var fetchResultsController: FetchedResultsControllerCombination2<String, PersistenceBrowserBanner, String, PersistenceBrowserFavourite>?
    
    private lazy var collectionViewLayout: Safari3WelcomeCollectionViewLayout = {
        let layout = Safari3WelcomeCollectionViewLayout()
        layout.delegate = self
        return layout
    }()
    
    private lazy var collectionView: DiffableCollectionView = {
        let collectionView = DiffableCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .hui_backgroundPrimary
        return collectionView
    }()
    
    private lazy var dataSource: Safari3WelcomeDataSource = {
        let dataSource = Safari3WelcomeDataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
    }()
    
    weak var delegate: Safari3WelcomeViewControllerDelegate?
    
    var account: PersistenceAccount? {
        didSet {
            refresh(
                withSelectedAccount: account
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        collectionView.contentInset = UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 16,
            right: 0
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.numberOfSections(in: collectionView) == 0 {
            dataSource.applyInitial()
        }
    }
    
    func refresh(
        withSelectedAccount account: PersistenceAccount?
    ) {
        guard let account = account
        else {
            fetchResultsController = nil
            dataSource.apply(
                banners: .init(),
                favourites: .init(),
                animated: true
            )
            return
        }
        
        fetchResultsController = FetchedResultsControllerCombination2(
            PersistenceBrowserBanner.fetchedResultsController(
                request: PersistenceBrowserBanner.fetchRequest()
            ),
            PersistenceBrowserFavourite.fetchedResultsController(
                request: PersistenceBrowserFavourite.fetchRequest(
                    account: account
                )
            ),
            results: { [weak self] banners, favourites in
                self?.dataSource.apply(
                    banners: banners,
                    favourites: favourites,
                    animated: true
                )
            }
        )

        try? fetchResultsController?.performFetch()
    }
    
    private func removeBrowserFavourite(
        _ favourite: PersistenceBrowserFavourite
    ) {
        let id = favourite.objectID
        Task { @PersistenceWritableActor in
            let object = PersistenceBrowserFavourite.writeableObject(id: id)
            try? object.delete()
        }
    }
}

extension Safari3WelcomeViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        switch item {
        case let .favourite(id):
            let favourite = PersistenceBrowserFavourite.readableObject(id: id)
            delegate?.safari3WelcomeViewController(
                self,
                didClickBrowserFavourite: favourite
            )
        case let .banner(id):
            let banner = PersistenceBrowserBanner.readableObject(id: id)
            delegate?.safari3WelcomeViewController(
                self,
                didClickBrowserBanner: banner
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }
        
        let favourite: PersistenceBrowserFavourite
        switch item {
        case let .favourite(id):
            favourite = PersistenceBrowserFavourite.readableObject(id: id)
        case .banner:
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(
                    children: [
                        UIAction(
                            title: "CommonDelete".asLocalizedKey,
                            attributes: .destructive,
                            handler: { [weak self] _ in
                                self?.removeBrowserFavourite(favourite)
                            }
                        )
                    ]
                )
            }
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        self.collectionView(
            collectionView,
            previewForContextMenuWithConfiguration: configuration
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        self.collectionView(
            collectionView,
            previewForContextMenuWithConfiguration: configuration
        )
    }
    
    private func collectionView(
        _ collectionView: UICollectionView,
        previewForContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewPreviewCell,
              let previewView = cell.contextMenuPreviewView
        else {
            return nil
        }
        
        let targetedPreview = UITargetedPreview(view: previewView)
        targetedPreview.parameters.backgroundColor = .clear
        return targetedPreview
    }
}

extension Safari3WelcomeViewController: Safari3WelcomeDataSourceDelegate {
    
    func safari3WelcomeDataSource(
        _ dataSource: Safari3WelcomeDataSource,
        emptyStateButtonDidClick view: Safari3WelcomePlaceholderCollectionReusableView
    ) {
        delegate?.safari3WelcomeViewController(
            self,
            didClickFavouritesEmptyView: view
        )
    }
}

extension Safari3WelcomeViewController: Safari3WelcomeCollectionViewLayoutDelegate {
    
    func safari3WelcomeCollectionViewSectionForIndex(
        index: Int
    ) -> Safari3WelcomeDataSource.Section? {
        dataSource.sectionIdentifier(forSectionIndex: index)
    }
}
