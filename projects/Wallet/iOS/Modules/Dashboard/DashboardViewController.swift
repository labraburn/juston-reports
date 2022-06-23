//
//  DashboardViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

class DashboardViewController: UIViewController {
    
    private var isInitialNavigationBarHidden = false
    private var fetchResultsController: FetchedResultsControllerCombination2<String, PersistencePendingTransaction, String, PersistenceProcessedTransaction>?
    
    private lazy var collectionViewLayout: DashboardCollectionViewLayout = {
        let layout = DashboardCollectionViewLayout()
        layout.delegate = self
        return layout
    }()
    
    private lazy var collectionView: DiffableCollectionView = {
        let collectionView = DiffableCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(reusableCellClass: DashboardTransactionCollectionViewCell.self)
        collectionView.backgroundColor = .hui_backgroundPrimary
        return collectionView
    }()
    
    private lazy var dataSource: DashboardDiffableDataSource = {
        let dataSource = DashboardDiffableDataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
    }()
    
    var account: PersistenceAccount? = nil {
        didSet {
            refresh(
                withSelectedAccount: account
            )
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        isInitialNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.isNavigationBarHidden = true
        
        dataSource.applyInitial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1
        {
            navigationController.isNavigationBarHidden = isInitialNavigationBarHidden
        }
    }
    
    private func refresh(
        withSelectedAccount account: PersistenceAccount?
    ) {
        guard let account = account
        else {
            fetchResultsController = nil
            dataSource.apply(
                pendingTransactions: .init(),
                processedTransactions: .init(),
                animated: true
            )
            return
        }

        let pendingTransactionsRequest = PersistencePendingTransaction.fetchRequest()
        pendingTransactionsRequest.predicate = NSPredicate(format: "account = %@", account)
        pendingTransactionsRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        let processedTransactionsRequest = PersistenceProcessedTransaction.fetchRequest()
        processedTransactionsRequest.predicate = NSPredicate(format: "account = %@", account)
        processedTransactionsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchResultsController = FetchedResultsControllerCombination2(
            PersistencePendingTransaction.fetchedResultsController(
                request: pendingTransactionsRequest
            ),
            PersistenceProcessedTransaction.fetchedResultsController(
                request: processedTransactionsRequest,
                sections: .day
            ),
            results: { [weak self] pendingTransactions, processedTransactions in
                self?.dataSource.apply(
                    pendingTransactions: pendingTransactions,
                    processedTransactions: processedTransactions,
                    animated: true
                )
            }
        )

        try? fetchResultsController?.performFetch()
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = account,
              let item = dataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        let transaction: TransactionDetailsViewable
        switch item {
        case let .pendingTransaction(id):
            transaction = PersistencePendingTransaction.readableObject(id: id)
        case let .processedTransaction(id):
            transaction = PersistenceProcessedTransaction.readableObject(id: id)
        }
        
        let viewController = TransactionDetailsViewController(
            account: account,
            transaction: transaction
        )
        
        let navigationController = NavigationController(rootViewController: viewController)
        hui_present(
            navigationController,
            animated: true
        )
    }
}

extension DashboardViewController: DashboardDiffableDataSourceDelegate {
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        emptyStateButtonDidClick view: DashboardPlaceholderCollectionReusableView
    ) {
        guard let account = account
        else {
            return
        }
        
        let viewController = QRSharingViewController(
            initialConfiguration: .init(
                address: Address(rawValue: account.selectedContract.address)
            )
        )
        
        let navigationController = NavigationController(rootViewController: viewController)
        hui_present(navigationController, animated: true)
    }
}

extension DashboardViewController: DashboardCollectionViewLayoutDelegate {
    
    func dashboardCollectionViewLayoutSectionForIndex(
        index: Int
    ) -> DashboardDiffableDataSource.Section? {
        dataSource.sectionIdentifier(forSectionIndex: index)
    }
}

extension DashboardViewController: ScrollToTopContainerController {
    
    var isScrolledToTop: Bool {
        collectionView.isScrolledToTop
    }
    
    func scrollToTop() {
        collectionView.scrollToTopIfPossible()
    }
}
