//
//  SCLS3000ViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

class SCLS3000ViewController: UIViewController {
    
    private lazy var collectionViewLayout: SCLS3000CompositionalLayout = {
        let layout = SCLS3000CompositionalLayout()
        layout.delegate = self
        return layout
    }()
    
    private lazy var collectionView: DiffableCollectionView = {
        let collectionView = DiffableCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .hui_backgroundPrimary
        return collectionView
    }()
    
    private lazy var dataSource: SCLS3000DataSource = {
        let dataSource = SCLS3000DataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
    }()
    
    private var isInitialNavigationBarHidden = false
    private var task: Task<(), Never>? {
        didSet {
            view.isUserInteractionEnabled = task == nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isInitialNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.isNavigationBarHidden = isInitialNavigationBarHidden
        }
    }
    
    // MARK: API
    
    func apply(
        snapshot: NSDiffableDataSourceSnapshot<SCLS3000Section, SCLS3000Item>,
        animatingDifferences: Bool = false
    ) {
        dataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }
}

extension SCLS3000ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        if let action = itemIdentifier.synchronousAction {
            do {
                try action()
            } catch {
                present(error)
            }
        }
        
        if let action = itemIdentifier.asynchronousAction {
            task?.cancel()
            task = Task {
                do {
                    try await action()
                } catch {
                    present(error)
                }
                task = nil
            }
        }
    }
}

extension SCLS3000ViewController: SCLS3000CompositionalLayoutDelegate {
    
    func collectionViewLayout(
        _ layout: SCLS3000CompositionalLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> SCLS3000Section? {
        dataSource.sectionIdentifier(forSectionIndex: sectionIndex)
    }
    
    func collectionViewLayout(
        _ layout: SCLS3000CompositionalLayout,
        numberOfItemsInSection sectionIndex: Int
    ) -> Int {
        dataSource.collectionView(collectionView, numberOfItemsInSection: sectionIndex)
    }
}

extension SCLS3000ViewController: SCLS3000DataSourceDelegate {
    
}
