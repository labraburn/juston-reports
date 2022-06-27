//
//  Safari3SearchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

protocol Safari3SearchViewControllerDelegate: AnyObject {
    
    func safari3SearchViewController(
        _ viewController: Safari3SearchViewController,
        didSelectBrowserFavourite favourite: PersistenceBrowserFavourite
    )
}

class Safari3SearchViewController: UIViewController {
    
    private var fetchResultsController: NSFetchedResultsController<PersistenceBrowserFavourite>?
    
    private lazy var collectionViewLayout: Safari3SearchCollectionViewLayout = {
        let layout = Safari3SearchCollectionViewLayout()
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
    
    private lazy var dataSource: Safari3SearchDataSource = {
        let dataSource = Safari3SearchDataSource(collectionView: collectionView)
        return dataSource
    }()
    
    weak var delegate: Safari3SearchViewControllerDelegate?
    
    var query: String? {
        didSet {
            refresh(
                withSelectedAccount: account,
                query: query
            )
        }
    }
    
    var account: PersistenceAccount? {
        didSet {
            refresh(
                withSelectedAccount: account,
                query: query
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
        withSelectedAccount account: PersistenceAccount?,
        query: String?
    ) {
        guard let account = account,
              let query = query,
              !query.isEmpty
        else {
            fetchResultsController = nil
            dataSource.applyInitial()
            return
        }

        fetchResultsController = PersistenceBrowserFavourite.fetchedResultsController(
            request: PersistenceBrowserFavourite.fetchRequest(
                account: account,
                query: query
            )
        )

        fetchResultsController?.delegate = self
        try? fetchResultsController?.performFetch()
    }
}

extension Safari3SearchViewController: NSFetchedResultsControllerDelegate {
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        dataSource.apply(
            favourites: snapshot,
            animated: false
        )
    }
}

extension Safari3SearchViewController: UICollectionViewDelegate {
    
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
            delegate?.safari3SearchViewController(
                self,
                didSelectBrowserFavourite: favourite
            )
        }
    }
}

extension Safari3SearchViewController: Safari3SearchCollectionViewLayoutDelegate {
    
    func safari3SearchCollectionViewSectionForIndex(
        index: Int
    ) -> Safari3SearchDataSource.Section? {
        dataSource.sectionIdentifier(forSectionIndex: index)
    }
}
