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
    
    private var task: Task<(), Never>? = nil
    
    private var fetchResultsController: NSFetchedResultsController<Transaction>?
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
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        fetch(accountsWithSelected: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.apply(transactions: [], animated: false)
    }
    
    // MARK: Private
    
    private func fetch(accountsWithSelected selected: Account?) {
        let request = Account.fetchRequest()
        let accounts = (try? PersistenceObject.fetch(request)) ?? []
        
        let cards: [DashboardStackView.Model] = accounts.map({ account in
            let model = DashboardStackView.Model(
                account: account,
                style: .image
            )
            return model
        })
        
        var _selected: DashboardStackView.Model?
        if let selected = selected, let index = cards.firstIndex(where: { $0.account == selected }) {
            _selected = cards[index]
        }
        
        accountsView.set(
            cards: cards,
            selected: _selected,
            animated: !accountsView.cards.isEmpty
        )
    }
    
    private func fetch(transactionsOfAccount account: Account) {
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "account = %@", account)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchResultsController = Transaction.fetchedResultsController(request: request)
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
    
    func dashboardAccountsViewShouldStartRefreshing(_ view: DashboardAccountsView) -> Bool {
        task == nil && !view.cards.isEmpty
    }
    
    func dashboardAccountsViewDidStartRefreshing(_ view: DashboardAccountsView) {
        guard let model = view.cards.first
        else {
            return
        }
        
        dashboardAccountsView(view, didChangeSelectedModel: model)
    }
    
    func dashboardAccountsViewIsUserInteractig(_ view: DashboardAccountsView) -> Bool {
        collectionView.isDragging || collectionView.isTracking || collectionView.isDecelerating
    }
    
    func dashboardAccountsView(_ view: DashboardAccountsView, addAccountButtonDidClick button: UIButton) {
        let viewController = AccountAddingViewController(model: .initial)
        viewController.delegate = self
        
        let navigationController = AccountAddingNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        hui_present(navigationController, animated: true, completion: nil)
    }
    
    func dashboardAccountsView(_ view: DashboardAccountsView, didChangeSelectedModel model: DashboardStackView.Model) {
        let account = model.account
        
        fetch(transactionsOfAccount: account)
        
        task?.cancel()
        task = Task { [weak self] in
            do {
                try await account.resynchronize()
            } catch {
                self?.presentAlertViewController(with: error)
            }
            
            self?.accountsView.stopLoadingIfAvailable()
            self?.task = nil
        }
    }
}

//
// MARK: AccountAddingViewControllerDelegate
//

extension DashboardViewController: AccountAddingViewControllerDelegate {
    
    func accountAddingViewController(
        _ viewController: AccountAddingViewController,
        didAddSaveAccount account: Account
    ) {
        fetch(accountsWithSelected: account)
    }
}

private extension DashboardStackView.Model.Style {
    
    static let `default` = DashboardStackView.Model.Style(
        textColorPrimary: .white,
        textColorSecondary: UIColor(rgb: 0x4F4F4F),
        borderColor: .white,
        backgroundImage: nil,
        backgroundColor: UIColor(rgb: 0x292528)
    )
    
    static let image = DashboardStackView.Model.Style(
        textColorPrimary: .white,
        textColorSecondary: .white.withAlphaComponent(0.6),
        borderColor: .white,
        backgroundImage: UIImage(named: "Image"),
        backgroundColor: UIColor(rgb: 0x292528)
    )
}
