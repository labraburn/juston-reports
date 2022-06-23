//
//  AccountStack.swift
//  iOS
//
//  Created by Anton Spivak on 23.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

protocol AccountStackViewControllerDelegate: CardStackViewControllerDelegate {}

class AccountStackViewController: UIViewController {
    
    private let cardStackViewController = CardStackViewController()
    private var animator: UIViewPropertyAnimator? = nil
    
    private var accountStackView: AccountStackView {
        view as! AccountStackView
    }
    
    weak var delegate: AccountStackViewControllerDelegate? {
        get { cardStackViewController.delegate as? AccountStackViewControllerDelegate }
        set { cardStackViewController.delegate = newValue }
    }
    
    var selectedCard: CardStackCard? { cardStackViewController.selectedCard }
    var cards: [CardStackCard] { cardStackViewController.cards }
    
    var layoutKind: AccountStackView.LayoutKind {
        get { accountStackView.layoutKind }
        set {
            guard accountStackView.layoutKind != newValue
            else {
                return
            }
            
            accountStackView.layoutKind = newValue
            
            endLayoutKindAnimations()
            startLayoutKindAnimations({
                self.accountStackView.setNeedsLayout()
                self.accountStackView.layoutIfNeeded()
            })
        }
    }
    
    override func loadView() {
        let accountStackView = AccountStackView()
        view = accountStackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(cardStackViewController)
        accountStackView.cardStackContainerView.enclosingView = cardStackViewController.cardStackView
        cardStackViewController.didMove(toParent: self)
        
        accountStackView.scanQRButton.addTarget(self, action: #selector(scanQRButtonDidClick(_:)), for: .touchUpInside)
        accountStackView.logotypeView.addTarget(self, action: #selector(logotypeControlDidClick(_:)), for: .touchUpInside)
        accountStackView.addAccountButton.addTarget(self, action: #selector(addAccountButtonDidClick(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountStackView.perfromApperingAnimation()
    }
    
    // MARK: Private
    
    private func startLayoutKindAnimations(
        _ block: @escaping () -> ()
    ) {
        animator = UIViewPropertyAnimator(
            duration: 0.26,
            timingParameters: UISpringTimingParameters(
                damping: 0.84,
                response: 0.48
            )
        )
        
        animator?.addAnimations(block)
        animator?.startAnimation()
    }
    
    private func endLayoutKindAnimations() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
    
    // MARK: Actions
    
    @objc
    private func addAccountButtonDidClick(
        _ sender: UIButton
    ) {
        // This is simple and low-weight and fast task
        Task {
            let navigationController = OnboardingNavigationController(
                initialConfiguration: await .dependsUserDefaults()
            )

            hui_present(navigationController, animated: true, completion: nil)
        }
    }

    @objc
    private func logotypeControlDidClick(
        _ sender: UIControl
    ) {
        let settingsNavigationController = C42NavigationController(
            rootViewController: SettingsViewController()
        )
        
        hui_present(settingsNavigationController, animated: true)
    }

    @objc
    private func scanQRButtonDidClick(
        _ sender: UIButton
    ) {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self

        let navigationController = NavigationController(rootViewController: qrViewController)
        hui_present(navigationController, animated: true, completion: nil)
    }
}

extension AccountStackViewController: CameraViewControllerDelegate {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeConvenienceURL convenienceURL: ConvenienceURL
    ) {
        let navigationController = viewController.navigationController
        
        switch convenienceURL {
        case let .transfer(destination, amount, text):
            guard let account = cardStackViewController.selectedCard?.account,
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
