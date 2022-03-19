//
//  DashboardViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI
import SwiftyTON
import Combine

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

class DashboardViewController: UIViewController {
    
    private let rawAddress = try! Address(base64EncodedString: "EQBKCMGcAoyyG85L3SIakVRLMfwhp7-xA13jTWAYO1jgpb81").raw
    private let storage = CodableStorage.target
    
    private var cancellables: Set<AnyCancellable> = []
    private var task: Task<(), Never>? = nil
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private let collectionViewLayout: DashboardCollectionViewLayout = DashboardCollectionViewLayout()
    private var collectionViewHeaderLayoutKind: DashboardCollectionHeaderView.LayoutType.Kind = .large
    
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
        collectionView.backgroundColor = .bui_backgroundSecondary
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
        
        view.backgroundColor = .bui_backgroundSecondary
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

        accountsView.cards = [
            .init(
                name: "Salary",
                address: "0x783ncytq783xmt83hmxt8h78thzht7xm3ht8c7h487cth/82",
                balanceBeforeDot: "25",
                balanceAfterDot: "000000009"
            ),
            .init(
                name: "Main",
                address: "0x783ncytq783xmt83hmxt8h78thzht7xm3ht8c7h487cth/82",
                balanceBeforeDot: "25",
                balanceAfterDot: "000000009"
            ),
            .init(
                name: "Blablabla",
                address: "0x783ncytq783xmt83hmxt8h78thzht7xm3ht8c7h487cth/82",
                balanceBeforeDot: "25",
                balanceAfterDot: "000000009"
            ),
        ]

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            if let wallet = try? await storage.value(of: Wallet.self, forKey: .wallet(for: rawAddress)) {
                let transactions = try? await storage.value(of: [Transaction].self, forKey: .lastTransactions(for: rawAddress))
                reload(wallet, with: transactions ?? [])
            } else {
                accountsViewStartLoadingAnimation()
                updateWalletIfAvailable()
            }
        }
    }
    
    // MARK: Private

    private func updateWalletIfAvailable() {
        guard task == nil
        else {
            return
        }
        
        accountsViewRefreshControlValue = .synchronization(value: 0)
        invalidateAccountsViewRefreshControlValue()
        
        task = Task {
            do {
                let wallet = try await Wallet(rawAddress: rawAddress)
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
        let rawAddress = rawAddress

        Task {
            try await storage.save(value: wallet, forKey: .wallet(for: rawAddress))
            if transactions.count > 0 {
                try await storage.save(value: transactions, forKey: .lastTransactions(for: rawAddress))
            }
        }

        accountsViewRefreshControlValue = .lastUpdatedDate(date: wallet.contract.info.synchronizationDate)
        invalidateAccountsViewRefreshControlValue()
        accountsViewFinishLoadingAnimationIfNeeded()

        dataSource.apply(
            wallet,
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
        
        let constant = scrollView.adjustedContentInset.top + scrollView.contentOffset.y
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        if velocity < 0 && constant > 42 {
            updateDashboardViewCollectionViewHeaderLayoutKind(.compact, animated: true)
        } else if velocity > 0 && constant < -42 {
            updateDashboardViewCollectionViewHeaderLayoutKind(.large, animated: true)
        }
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
            UIView.animate(
                withDuration: 0.21,
                delay: 0,
                usingSpringWithDamping: 0.88,
                initialSpringVelocity: 0.0,
                options: [.allowUserInteraction],
                animations: {
                    collectionView.layoutIfNeeded()
                }, completion: { _ in }
            )
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
        task == nil
    }
    
    func dashboardAccountsViewDidStartRefreshing(_ view: DashboardAccountsView) {
        updateWalletIfAvailable()
    }
    
    func dashboardAccountsViewIsUserInteractig(_ view: DashboardAccountsView) -> Bool {
        collectionView.isDragging || collectionView.isTracking || collectionView.isDecelerating
    }
    
    func dashboardAccountsView(_ view: DashboardAccountsView, didChangeSelectedModel model: DashboardStackView.Model) {
        
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
