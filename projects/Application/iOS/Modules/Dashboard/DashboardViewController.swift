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
    private var accountsObserver: NSObjectProtocol?
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private let collectionViewLayout: DashboardCollectionViewLayout = DashboardCollectionViewLayout()
    private var collectionViewHeaderLayoutKind: DashboardCollectionHeaderView.LayoutType.Kind = .large
    private var collectionViewPreviousContentOffset: CGPoint = .zero
    private var collectionViewHeaderLayoutKindAnimator: UIViewPropertyAnimator?
    
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
        accountsObserver?.removeFromNotificationCenter()
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        accountsObserver = PersistenceObject.observeManagedObjectContextObjectsDidChange({ [weak self] notification in
            guard let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<PersistenceAccount>
            else {
                return
            }
            
            self?.reload(withSelectedAccount: Array(inserted).first)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isInitialNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.isNavigationBarHidden = true
        
        if accountsView.superview == nil {
            // Force appearing of empty state
            UIView.performWithoutAnimation({
                dataSource.apply(transactions: [], animated: false)
                reload(withSelectedAccount: nil)
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
    
    private func reload(withSelectedAccount selected: PersistenceAccount?) {
        let cardsRequest = PersistenceAccount.fetchRequest()
        let cards = ((try? PersistenceObject.fetch(cardsRequest)) ?? []).map({
            DashboardStackView.Model(
                account: $0
            )
        })
        
        guard !cards.isEmpty
        else {
            accountsView.set(cards: [], selected: nil, animated: true)
            return
        }
        
        let _selected: DashboardStackView.Model
        if let selected = selected {
            _selected = cards.first(where: { $0.account == selected }) ?? cards[0]
        } else if !(accountsView.selected?.account.isFault ?? true) {
            _selected = accountsView.selected ?? cards[0]
        } else {
            _selected = cards[0]
        }
        
        accountsView.set(
            cards: cards,
            selected: _selected,
            animated: true
        )
        
        let transactionsRequest = PersistenceTransaction.fetchRequest()
        transactionsRequest.predicate = NSPredicate(format: "account = %@", _selected.account)
        transactionsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchResultsController = PersistenceTransaction.fetchedResultsController(request: transactionsRequest)
        fetchResultsController?.delegate = self
        
        try? fetchResultsController?.performFetch()
    }
}

// MARK: DashboardViewController: NSFetchedResultsControllerDelegate

extension DashboardViewController: NSFetchedResultsControllerDelegate {
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let objects = snapshot.itemIdentifiers.compactMap({ $0 as? NSManagedObjectID })
        dataSource.apply(transactions: objects, animated: true)
    }
}

// MARK:  DashboardViewController: UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {
    
}

// MARK:  DashboardViewController: UIScrollViewDelegate

extension DashboardViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        accountsView.enclosingScrollViewWillStartDraging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        accountsView.enclosingScrollViewDidScroll(scrollView)
        
        guard !accountsView.cards.isEmpty
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

// MARK:  DashboardViewController: DashboardDiffableDataSourceDelegate

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

// MARK:  DashboardViewController: CollectionViewHeaderLayoutKind

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
        case .compact:
            collectionViewLayout.refreshLayoutConfiguration(pinToVisibleBounds: true)
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
// MARK:  DashboardViewController: DashboardAccountsViewDelegate
//

extension DashboardViewController: DashboardAccountsViewDelegate {
    
    func dashboardAccountsViewShouldStartRefreshing(
        _ view: DashboardAccountsView
    ) -> Bool {
        task == nil && !view.cards.isEmpty
    }
    
    func dashboardAccountsViewDidStartRefreshing(
        _ view: DashboardAccountsView
    ) {
        guard let model = view.cards.first
        else {
            return
        }
        
        refresh(account: model.account, manually: true)
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
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didChangeSelectedModel model: DashboardStackView.Model
    ) {
        let account = model.account
        
        reload(withSelectedAccount: account)
        refresh(account: account, manually: false)
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickRemoveButtonWithModel model: DashboardStackView.Model
    ) {
        let viewController = AlertViewController(
            image: .image(.hui_warning42, tintColor: .hui_letter_red),
            title: "CommonAttention".asLocalizedKey,
            message: "AccountDeletePromptMessage".asLocalizedKey,
            actions: [
                .init(
                    title: "AccountDeleteDestructiveTitle".asLocalizedKey,
                    block: { viewController in
                        try? model.account.delete()
                        self.reload(withSelectedAccount: nil)
                        viewController.dismiss(animated: true)
                    },
                    style: .destructive
                ),
                .cancel
            ]
        )
        present(viewController, animated: true)
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickSendButtonWithModel model: DashboardStackView.Model
    ) {
        presentUnderDevelopment()
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickReceiveButtonWithModel model: DashboardStackView.Model
    ) {
        presentUnderDevelopment()
    }
    
    private func refresh(account: PersistenceAccount, manually: Bool) {
        task?.cancel()
        task = Task { [weak self] in
            do {
                let synchronization = await Synchronization()
                try await synchronization.perform(
                    rawAddress: account.rawAddress,
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
}
