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

// Balance: ?
// Address: "EQBKCMGcAoyyG85L3SIakVRLMfwhp7-xA13jTWAYO1jgpb81" // v4
// Words: []

// Balance: ?
// Address: "EQCMfNwPB8TaNqQ9hnXCYcXOz41jfI5PCawHe1ZvwKfKXTXM" // united
// Words: []

// Balance: 14.9
// Address: EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk
// Address: EQCIJiFJrN8kuwdXEIfmJ-D7qwP-QfLX8YtCAhaY6AoSKxUv ????????????????????????????????
// Words: ["episode", "diary", "tower", "either", "void", "into", "until", "universe", "loan", "answer", "own", "ribbon", "adapt", "step", "tuna", "innocent", "accident", "female", "already", "nasty", "wrist", "tenant", "toast", "post"]

class DashboardViewController: UIViewController {
    
    private var dashboardView: DashboardView { view as! DashboardView }
    private let address: Address
    private let storage = CodableStorage.target
    
    private var cancellables: Set<AnyCancellable> = []
    private var task: Task<(), Never>? = nil
    
    private lazy var dataSource: DashboardDiffableDataSource = {
        let dataSource = DashboardDiffableDataSource(collectionView: dashboardView.collectionView)
        return dataSource
    }()
    
    init(address: Address) {
//        self.address = address
        self.address = Address(rawValue: "EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk")
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
        task?.cancel()
    }
    
    override func loadView() {
        let view = DashboardView()
        view.delegate = self
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dashboardView.logoView.update(presentation: .on)
        dashboardView.refreshControlValue = .text(value: "")
        dashboardView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        SwiftyTONSynchronization()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] progress in
                guard let self = self, progress > 0, progress < 1
                else {
                    return
                }
            
                let view = self.dashboardView
                view.refreshControlValue = .synchronization(value: progress)
            })
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            if let wallet = try? await storage.value(of: Wallet.self, forKey: .wallet(for: address)) {
                reload(wallet)
            } else {
                dashboardView.startLoadingAnimation()
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
        
        task = Task {
            do {
                let wallet = try await Wallet.download(for: address)
                reload(wallet)
            } catch {
                dashboardView.finishLoadingAnimationIfNeeded()
                presentAlertViewController(with: error)
            }

            task = nil
        }
    }
    
    private func reload(_ wallet: Wallet, animated: Bool = true) {
        let storage = storage
        let address = address
        
        Task {
            try await storage.save(value: wallet, forKey: .wallet(for: address))
        }
        
        dashboardView.refreshControlValue = .lastUpdatedDate(date: wallet.info.synchronizationDate)
        dashboardView.finishLoadingAnimationIfNeeded()
        
        dataSource.apply(
            wallet,
            animated: animated && viewIfLoaded?.window != nil
        )
    }
}

extension DashboardViewController: CollectionCompositionViewDelegate {
    
    func collectionCompositionViewShouldStartReload(_ view: CollectionCompositionView) -> Bool {
        updateWalletIfAvailable()
        return true
    }
}

fileprivate extension CodableStorage.Key {
    
    static func wallet(for address: Address) -> CodableStorage.Key {
        CodableStorage.Key(rawValue: "wallet_\(address.rawValue)")
    }
}
