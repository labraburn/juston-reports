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
    private var task: Task<(), Never>? = nil
    
    private var fetchResultsController: NSFetchedResultsController<PersistenceTransaction>?
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var collectionViewHeaderLayoutKind: DashboardCollectionHeaderView.LayoutType.Kind = .large
    private var collectionViewPreviousContentOffset: CGPoint = .zero
    private var collectionViewHeaderLayoutKindAnimator: UIViewPropertyAnimator?
    
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
        collectionView.register(reusableSupplementaryViewClass: DashboardCollectionHeaderView.self)
        collectionView.register(reusableCellClass: DashboardTransactionCollectionViewCell.self)
        collectionView.backgroundColor = .hui_backgroundPrimary
        return collectionView
    }()
    
    private lazy var cardsStackViewController: CardStackViewController = {
        let viewController = CardStackViewController()
        viewController.delegate = self
        return viewController
    }()
    
    private lazy var accountsView: DashboardAccountsView = {
        let accountsView = DashboardAccountsView()
        accountsView.delegate = self
        return accountsView
    }()
    
    private lazy var dataSource: DashboardDiffableDataSource = {
        let dataSource = DashboardDiffableDataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        addChild(cardsStackViewController)
        accountsView.cardStackView = cardsStackViewController.cardStackView
        cardsStackViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isInitialNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.isNavigationBarHidden = true
        
        floatingTabBarController?.floatingTabBar.setFloatingHidden(
            collectionViewHeaderLayoutKind == .large,
            animated: animated
        )
        
        if accountsView.superview == nil && dataSource.snapshot().itemIdentifiers.isEmpty {
            // Force appearing of empty state
            UIView.performWithoutAnimation({
                dataSource.apply(transactions: .init(), animated: false)
                collectionView.layoutIfNeeded()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.isNavigationBarHidden = isInitialNavigationBarHidden
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showParoleViewControllerIfNeeded()
    }
    
    // MARK: Private
    
    private func showParoleViewControllerIfNeeded() {
        Task {
            let parole = SecureParole()
            let isKeyGenerated = await parole.isKeyGenerated
            
            guard !isKeyGenerated
            else {
                return
            }
            
            let viewController = OnboardingViewController()
            hui_present(viewController, animated: true)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension DashboardViewController: NSFetchedResultsControllerDelegate {
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let casted = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        dataSource.apply(transactions: casted, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {
    
}

// MARK: - UIScrollViewDelegate

extension DashboardViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        accountsView.enclosingScrollViewWillStartDraging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        accountsView.enclosingScrollViewDidScroll(scrollView)

        guard !cardsStackViewController.cards.isEmpty
        else {
            return
        }

        let constant = scrollView.adjustedContentInset.top + scrollView.contentOffset.y

        let isScrollingTop = collectionViewPreviousContentOffset.y - scrollView.contentOffset.y < 0
        let isScrollingBottom = collectionViewPreviousContentOffset.y - scrollView.contentOffset.y > 0

        if isScrollingTop && constant > 42 {
            updateDashboardViewCollectionViewHeaderLayoutKind(.compact, animated: true)
        } else if isScrollingBottom && constant < -42 && scrollView.isTracking {
            updateDashboardViewCollectionViewHeaderLayoutKind(.large, animated: true)
        }

        collectionViewPreviousContentOffset = scrollView.contentOffset
    }
}

// MARK: - DashboardDiffableDataSourceDelegate

extension DashboardViewController: DashboardDiffableDataSourceDelegate {
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        subviewForCollectionHeaderView view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderSubview {
        accountsView
    }
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        layoutTypeForCollectionHeaderView view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderView.LayoutType {
        DashboardCollectionHeaderView.LayoutType(
            bounds: self.view.bounds,
            safeAreaInsets: self.view.safeAreaInsets,
            kind: collectionViewHeaderLayoutKind
        )
    }
}

// MARK: - CollectionViewHeaderLayoutKind

extension DashboardViewController {
    
    func updateDashboardViewCollectionViewHeaderLayoutKind(
        _ layoutTypeKind: DashboardCollectionHeaderView.LayoutType.Kind,
        animated: Bool
    ) {
        guard collectionViewHeaderLayoutKind != layoutTypeKind
        else {
            return
        }
        
        collectionViewHeaderLayoutKind = layoutTypeKind
        impactFeedbackGenerator.impactOccurred()
        
        switch layoutTypeKind {
        case .large:
            collectionViewLayout.refreshLayoutConfiguration(pinToVisibleBounds: false)
            floatingTabBarController?.floatingTabBar.setFloatingHidden(true, animated: true)
        case .compact:
            collectionViewLayout.refreshLayoutConfiguration(pinToVisibleBounds: true)
            floatingTabBarController?.floatingTabBar.setFloatingHidden(false, animated: true)
        }
        
        let collectionView = collectionView
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.invalidateIntrinsicContentSize()
        collectionView.setNeedsLayout()
        
        if animated {
            collectionViewHeaderLayoutKindAnimator?.stopAnimation(true)
            
            let timing = UISpringTimingParameters(damping: 0.74, response: 0.46)
            collectionViewHeaderLayoutKindAnimator = UIViewPropertyAnimator(duration: 0.16, timingParameters: timing)
            collectionViewHeaderLayoutKindAnimator?.addAnimations({
                collectionView.layoutIfNeeded()
            })
            
            collectionViewHeaderLayoutKindAnimator?.startAnimation()
        } else {
            collectionView.layoutIfNeeded()
        }
    }
}

//
// MARK: - DashboardViewController: DashboardAccountsViewDelegate
//

extension DashboardViewController: DashboardAccountsViewDelegate {
    
    func dashboardAccountsViewShouldStartRefreshing(
        _ view: DashboardAccountsView
    ) -> Bool {
        task == nil && !cardsStackViewController.cards.isEmpty
    }
    
    func dashboardAccountsViewDidStartRefreshing(
        _ view: DashboardAccountsView
    ) {
        guard let model = cardsStackViewController.cards.first
        else {
            return
        }

        refresh(
            withSelectedAccount: model.account,
            manually: true
        )
    }
    
    func dashboardAccountsViewIsUserInteractig(
        _ view: DashboardAccountsView
    ) -> Bool {
        collectionView.isDragging || collectionView.isTracking || collectionView.isDecelerating
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        addAccountButtonDidClick button: UIButton
    ) {
        let navigationController = AccountAddingViewController()
        hui_present(navigationController, animated: true, completion: nil)
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        scanQRButtonDidClick button: UIButton
    ) {
        presentUnderDevelopment()
    }
}

//
// MARK: - CardStackViewControllerDelegate
//

extension DashboardViewController: CardStackViewControllerDelegate {
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didChangeSelectedModel model: CardStackCard?
    ) {
        refresh(
            withSelectedAccount: model?.account,
            manually: false
        )
    }
    
    private func refresh(
        withSelectedAccount account: PersistenceAccount?,
        manually: Bool
    ) {
        guard let account = account
        else {
            fetchResultsController = nil
            dataSource.apply(transactions: .init(), animated: true)
            return
        }

        let transactionsRequest = PersistenceTransaction.fetchRequest()
        transactionsRequest.predicate = NSPredicate(format: "account = %@", account)
        transactionsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        fetchResultsController = PersistenceTransaction.fetchedResultsController(
            request: transactionsRequest,
            sections: .day
        )
        fetchResultsController?.delegate = self

        try? fetchResultsController?.performFetch()
        
        task?.cancel()
        task = Task { [weak self] in
            do {
                let synchronization = Synchronization()
                try await synchronization.perform(
                    address: account.selectedAddress,
                    transactionReceiveOptions: .afterLastSaved
                )
                self?.accountsView.stopLoadingIfAvailable()
            } catch is CancellationError {
                if !manually {
                    // Seems like we are manually cancelled task by refresh control
                    self?.accountsView.stopLoadingIfAvailable()
                }
            } catch {
                self?.present(error)
                self?.accountsView.stopLoadingIfAvailable()
            }
            self?.task = nil
        }
    }
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didClickAtModel model: CardStackCard?
    ) {
        switch collectionViewHeaderLayoutKind {
        case .large:
            updateDashboardViewCollectionViewHeaderLayoutKind(.compact, animated: true)
        case .compact:
            if !isScrolledToTop {
                scrollToTop()
            } else {
                updateDashboardViewCollectionViewHeaderLayoutKind(.large, animated: true)
            }
        }
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
