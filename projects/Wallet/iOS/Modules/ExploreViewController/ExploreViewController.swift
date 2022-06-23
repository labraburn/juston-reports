//
//  ExploreViewController.swift
//  iOS
//
//  Created by Anton Spivak on 22.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class ExploreViewController: TripleViewController {
    
    private let synchronizationLoop = SynchronizationLoop()
    private var isInitialized: Bool = false
    
    private var account: PersistenceAccount? = nil {
        didSet {
            transactionsViewController.account = account
            if let account = account {
                let address = Address(rawValue: account.selectedContract.address)
                synchronizationLoop.use(address: address)
            } else {
                synchronizationLoop.use(address: nil)
            }
        }
    }
    
    private var accountStackViewController: AccountStackViewController {
        viewControlles.1 as! AccountStackViewController
    }
    
    private var transactionsViewController: TransactionsViewController {
        viewControlles.2 as! TransactionsViewController
    }

    init() {
        super.init((
            UIViewController().with({ $0.view.backgroundColor = .green }),
            AccountStackViewController(),
            TransactionsViewController()
        ))
        
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        accountStackViewController.delegate = self
        account = accountStackViewController.selectedCard?.account
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnboardingViewControllerIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !isInitialized
        else {
            return
        }
        
        isInitialized = true
        update(
            presentation: .middle,
            animated: false
        )
    }
    
    // MARK: API
    
    func showTransferViewControllerIfAvailable(
        destination: Address,
        amount: Currency?,
        message: String?
    ) {
        guard let account = accountStackViewController.selectedCard?.account,
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
        let isCardsEmpty = accountStackViewController.cards.isEmpty
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

extension ExploreViewController: AccountStackViewControllerDelegate {
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didChangeSelectedModel model: CardStackCard?
    ) {
        account = model?.account
    }
    
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didClickAtModel model: CardStackCard?
    ) {
        switch presentation {
        case .top, .bottom:
            update(presentation: .middle, animated: true)
        case .middle:
            break
        }
    }
}

extension ExploreViewController: TripleViewControllerDelegate {
    
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangeOffset offset: CGPoint
    ) {
    }
    
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangePresentation presentation: TriplePresentation
    ) {
        switch presentation {
        case .top:
            accountStackViewController.layoutKind = .compact(
                height: compactHeight,
                pin: .top
            )
        case .middle:
            accountStackViewController.layoutKind = .large
        case .bottom:
            accountStackViewController.layoutKind = .compact(
                height: compactHeight,
                pin: .bottom
            )
        }
    }
}
