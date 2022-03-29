//
//  DashboardViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import HuetonUI
import SwiftyTON
import Combine

class DashboardViewController: UIViewController {
    
    private let storage = CodableStorage.target
    
    private var cancellables: Set<AnyCancellable> = []
    private var task: Task<(), Never>? = nil
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private let collectionViewLayout: DashboardCollectionViewLayout = DashboardCollectionViewLayout()
    private var collectionViewHeaderLayoutKind: DashboardCollectionHeaderView.LayoutType.Kind = .large
    private var collectionViewPreviousContentOffset: CGPoint = .zero
    private var collectionViewHeaderLayoutKindAnimator: UIViewPropertyAnimator?
    
    private var accountsViewRefreshControlValue: AccountsViewRefreshControlValue = .text(value: "")
    private var accountsViewRefreshControlValueTimer: Timer? = nil
    
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
        accountsView.refreshControlPresentation = .on
        accountsView.refreshControlText = ""
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
        accountsViewRefreshControlValueTimer?.invalidate()
        cancellables.forEach({ $0.cancel() })
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        accountsViewRefreshControlValueTimer?.invalidate()
        accountsViewRefreshControlValueTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self] timer in
                guard let self = self
                else {
                    timer.invalidate()
                    return
                }

                self.invalidateAccountsViewRefreshControlValue()
            }
        )

        SwiftyTONSynchronization()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] progress in
                guard let self = self, progress > 0, progress < 1
                else {
                    return
                }

                self.accountsViewRefreshControlValue = .synchronization(value: progress)
                self.invalidateAccountsViewRefreshControlValue()
            })
            .store(in: &cancellables)
        
        task = Task { [weak self] in
            let accounts = await CodableStorage.group.methods.accounts()
            self?.task = nil
            
            updateAccounts(accounts)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.apply(transactions: [], animated: true)
//        Task {
//            if let wallet = try? await storage.value(of: Wallet.self, forKey: .wallet(for: rawAddress)) {
//                let transactions = try? await storage.value(of: [Transaction].self, forKey: .lastTransactions(for: rawAddress))
//                reload(wallet, with: transactions ?? [])
//            } else {
//                accountsViewStartLoadingAnimation()
//                updateWalletIfAvailable()
//            }
//        }
    }
    
    // MARK: Private
    
    private func updateAccounts(_ accounts: [Account], selected: Account? = nil) {
        let cards: [DashboardStackView.Model] = accounts.map({ account in
            let model = DashboardStackView.Model(
                account: account,
                balanceBeforeDot: "0",
                balanceAfterDot: "0",
                style: .default
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
        
        guard !accounts.isEmpty
        else {
            dataSource.apply(transactions: [], animated: true)
            return
        }
        
        updateAccountIfAvailable(account: accounts[0])
    }

    private func updateAccountIfAvailable(account: Account) {
        guard task == nil
        else {
            return
        }
        
        accountsViewRefreshControlValue = .synchronization(value: 0)
        invalidateAccountsViewRefreshControlValue()
        
        task = Task {
            do {
                let wallet = try await Wallet(rawAddress: account.rawAddress)
                let transactions = try await wallet.contract.transactions()
                reload(wallet, with: transactions)
            } catch {
                presentAlertViewController(with: error)
            }
            
            accountsViewFinishLoadingAnimationIfNeeded()
            task = nil
        }
    }
    
    private func reload(_ wallet: Wallet, with transactions: [Transaction], animated: Bool = true) {
        let storage = storage
        let rawAddress = wallet.contract.rawAddress

        Task {
            try await storage.save(value: wallet, forKey: .wallet(for: rawAddress))
            try await storage.save(value: transactions, forKey: .lastTransactions(for: rawAddress))
        }

        accountsViewRefreshControlValue = .lastUpdatedDate(date: wallet.contract.info.synchronizationDate)
        invalidateAccountsViewRefreshControlValue()
        accountsViewFinishLoadingAnimationIfNeeded()

        dataSource.apply(
            transactions: transactions,
            animated: animated && viewIfLoaded?.window != nil
        )
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
            
            let timing = UISpringTimingParameters(damping: 0.9, response: 0.36)
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
        guard let account = view.cards.first?.account
        else {
            return
        }
        
        updateAccountIfAvailable(account: account)
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
        
    }
}

//
// MARK:
//

extension DashboardViewController: AccountAddingViewControllerDelegate {
    
    func accountAddingViewController(
        _ viewController: AccountAddingViewController,
        didAddSaveAccount account: Account,
        into accounts: [Account]
    ) {
        updateAccounts(accounts, selected: account)
    }
}

//
// MARK:  DashboardViewController: LoadingAnimation & RefreshControlValue
//

extension DashboardViewController {
    
    enum AccountsViewRefreshControlValue: Equatable {
        
        case text(value: String)
        case synchronization(value: Double)
        case lastUpdatedDate(date: Date)
    }
    
    private func accountsViewStartLoadingAnimation() {
        accountsView.startLoadingAnimationIfAvailable()
    }
    
    private func accountsViewFinishLoadingAnimationIfNeeded() {
        accountsView.stopLoadingIfAvailable()
    }
    
    private func invalidateAccountsViewRefreshControlValue() {
        switch accountsViewRefreshControlValue {
        case let .text(value):
            accountsView.refreshControlText = value
        case let .lastUpdatedDate(date):
            let formatter = RelativeDateTimeFormatter.shared
            let timeAgo = formatter.localizedString(for: Date(), relativeTo: date)
            accountsView.refreshControlText = "Updated \(timeAgo) ago"
        case let .synchronization(value):
            accountsView.refreshControlText = "Syncing.. \(Int(value * 100))%"
        }
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

// PROD
//
// Balance: ?
// Address: "EQBKCMGcAoyyG85L3SIakVRLMfwhp7-xA13jTWAYO1jgpb81" // v4r2
// Words: []

// PROD
//
// Balance: ?
// Address: "EQCMfNwPB8TaNqQ9hnXCYcXOz41jfI5PCawHe1ZvwKfKXTXM" // united
// Words: []

// PROD
//
// Balance: 34
// Address: EQCd3ASamrfErTV4K6iG5r0o3O_hl7K_9SghU0oELKF-sxDn // v3r2
// Words: []

// TEST
//
// Balance: 14.9
// Address: EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk
// Address: EQCIJiFJrN8kuwdXEIfmJ-D7qwP-QfLX8YtCAhaY6AoSKxUv ????????????????????????????????
// Words: ["episode", "diary", "tower", "either", "void", "into", "until", "universe", "loan", "answer", "own", "ribbon", "adapt", "step", "tuna", "innocent", "accident", "female", "already", "nasty", "wrist", "tenant", "toast", "post"]
