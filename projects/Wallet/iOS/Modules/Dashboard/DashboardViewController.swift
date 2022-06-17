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
    
    private let synchronizationLoop = SynchronizationLoop()
    private var isInitialNavigationBarHidden = false
    
    private var fetchResultsController: FetchedResultsControllerCombination2<String, PersistencePendingTransaction, String, PersistenceProcessedTransaction>?
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
        
        if accountsView.superview == nil,
           dataSource.snapshot().itemIdentifiers.isEmpty
        {
            // Force appearing of empty state
            UIView.performWithoutAnimation({
                dataSource.apply(
                    pendingTransactions: .init(),
                    processedTransactions: .init(),
                    animated: true
                )
                collectionView.layoutIfNeeded()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1
        {
            navigationController.isNavigationBarHidden = isInitialNavigationBarHidden
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnboardingViewControllerIfNeeded()
        accountsView.perfromApperingAnimation()
    }
    
    // MARK: API
    
    func showTransferViewControllerIfAvailable(
        destination: Address,
        amount: Currency?,
        message: String?
    ) {
        guard let account = cardsStackViewController.selectedCard?.account,
              let key = account.keyIfAvailable
        else {
            return
        }
        
        let viewController = TransferNavigationController(
            initialConfiguration: .init(
                fromAccount: account,
                toAddress: destination,
                key: key,
                amount: amount,
                message: message
            )
        )
        
        topmostPresentedViewController.hui_present(
            viewController,
            animated: true
        )
    }
    
    // MARK: Private
    
    fileprivate func showOnboardingViewControllerIfNeeded() {
        let isCardsEmpty = cardsStackViewController.cards.isEmpty
        Task {
            let initialConfiguration = await OnboardingNavigationController.InitialConfiguration.dependsUserDefaults()
            
            /// cards > 1 means not only `[.account]`
            guard initialConfiguration.screens.count > 1 || isCardsEmpty
            else {
                return
            }
            
            let navigationController = OnboardingNavigationController(
                initialConfiguration: initialConfiguration
            )
            
            hui_present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = cardsStackViewController.selectedCard?.account,
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

// MARK: - UIScrollViewDelegate

extension DashboardViewController: UIScrollViewDelegate {
    
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
            bounds: CGRect(
                origin: .zero,
                size: CGSize(
                    width: self.view.bounds.width,
                    height: self.view.bounds.height + self.view.safeAreaInsets.bottom
                )
            ),
            safeAreaInsets: self.view.safeAreaInsets,
            kind: collectionViewHeaderLayoutKind
        )
    }
    
    func dashboardDiffableDataSource(
        _ dataSource: DashboardDiffableDataSource,
        emptyStateButtonDidClick view: DashboardPlaceholderCollectionReusableView
    ) {
        guard let account = cardsStackViewController.selectedCard?.account
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
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        addAccountButtonDidClick button: UIButton
    ) {
        // This is simple and low-weight and fast task
        Task {
            let navigationController = OnboardingNavigationController(
                initialConfiguration: await .dependsUserDefaults()
            )
            
            hui_present(navigationController, animated: true, completion: nil)
        }
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        logotypeControlDidClick button: UIControl
    ) {
        let settingsNavigationController = C42NavigationController(rootViewController: SettingsViewController())
        hui_present(settingsNavigationController, animated: true)
    }
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        scanQRButtonDidClick button: UIButton
    ) {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self
        
        let navigationController = NavigationController(rootViewController: qrViewController)
        hui_present(navigationController, animated: true, completion: nil)
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
            withSelectedAccount: model?.account
        )
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
        synchronizationLoop.use(address: Address(rawValue: account.selectedContract.address))
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

extension DashboardViewController: CameraViewControllerDelegate {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeConvenienceURL convenienceURL: ConvenienceURL
    ) {
        let navigationController = viewController.navigationController
        
        switch convenienceURL {
        case let .transfer(destination, amount, text):
            guard let account = cardsStackViewController.selectedCard?.account,
                  let key = account.keyIfAvailable
            else {
                return
            }
            
            let viewController = TransferDetailsViewController(
                initialConfiguration: .init(
                    fromAccount: account,
                    toAddress: destination,
                    key: key,
                    amount: amount,
                    message: text
                )
            )
            
            navigationController?.pushViewController(
                viewController,
                animated: true
            )
        }
    }
}
