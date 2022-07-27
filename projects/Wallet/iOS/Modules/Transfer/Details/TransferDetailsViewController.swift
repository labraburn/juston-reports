//
//  TransferDetailsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI
import JustonCORE

class TransferDetailsViewController: FormViewController {
    
    private let initialConfiguration: InitialConfiguration
    private var transferConfiguration: TransferConfiguration?

    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TransferDetailsTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .jus_backgroundPrimary
        
        reload(
            using: initialConfiguration.configuration,
            isEditable: initialConfiguration.isEditable
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let addressInput = formInput(at: IndexPath(item: 1, section: 0)),
              let amountInput = formInput(at: IndexPath(item: 2, section: 0))
        else {
            return
        }
        
        if addressInput.text.isEmpty {
            addressInput.makeFirstResponder()
        } else if amountInput.text.isEmpty {
            amountInput.makeFirstResponder()
        }
    }
    
    private func openCameraViewController() {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self
        
        let navigationController = NavigationController(rootViewController: qrViewController)
        jus_present(navigationController, animated: true, completion: nil)
    }
    
    private func reload(
        using transferConfiguration: TransferConfiguration?,
        isEditable: Bool,
        animatingDifferences: Bool = true
    ) {
        self.transferConfiguration = transferConfiguration
        apply(
            items(
                using: transferConfiguration,
                isEditable: isEditable
            ),
            in: .simple(
                models: buttons(using: transferConfiguration)
            ),
            animatingDifferences: animatingDifferences
        )
    }
    
    // MARK: Configuration
    
    private func items(
        using transferConfiguration: TransferConfiguration?,
        isEditable: Bool
    ) -> [FormCollectionViewItem] {
        let actions: [BorderedTextView.Action] = [
            .init(
                image: .jus_scan20,
                block: { [weak self] in
                    self?.openCameraViewController()
                }
            )
        ]
        
        var items: [FormCollectionViewItem] = [
            .text(
                model: .init(
                    text: "TransferDetailsDescription".asLocalizedKey,
                    alignment: .center,
                    style: .headline
                )
            ),
            .input(
                model: .init(
                    text: transferConfiguration?.destination.displayName,
                    placeholder: "TransferDetailsAddressDescription".asLocalizedKey,
                    keyboardType: .asciiCapable,
                    returnKeyType: .next,
                    autocorrectionType: .no,
                    autocapitalizationType: .none,
                    maximumContentSizeHeight: 42,
                    minimumContentSizeHeight: 21,
                    isEditable: isEditable,
                    actions: isEditable ? actions : []
                )
            ),
            .input(
                model: .init(
                    text: transferConfiguration?.amount?.string(with: .maximum9),
                    placeholder: "CommonAmount".asLocalizedKey,
                    keyboardType: .decimalPad,
                    returnKeyType: .next,
                    autocorrectionType: .no,
                    autocapitalizationType: .none,
                    maximumContentSizeHeight: 42,
                    minimumContentSizeHeight: 21,
                    isEditable: isEditable,
                    actions: []
                )
            ),
        ]
        
        guard transferConfiguration?.payload == nil,
              transferConfiguration?.initial == nil
        else {
            return items
        }
        
        items.append(
            .input(
                model: .init(
                    text: transferConfiguration?.message,
                    placeholder: "TransferDetailsMessageDescription".asLocalizedKey,
                    keyboardType: .default,
                    returnKeyType: .default,
                    autocorrectionType: .default,
                    autocapitalizationType: .sentences,
                    maximumContentSizeHeight: 128,
                    minimumContentSizeHeight: 64,
                    isEditable: isEditable,
                    actions: []
                )
            )
        )
        
        return items
    }
    
    private func buttons(
        using transferConfiguration: TransferConfiguration?
    ) -> [FormButtonsCollectionReusableView.Model] {
        var backButtonTitle = "CommonCancel".asLocalizedKey.uppercased()
        if let navigationController = navigationController, navigationController.viewControllers.first != self {
            backButtonTitle = "CommonBack".asLocalizedKey.uppercased()
        }
        
        let buttons: [FormButtonsCollectionReusableView.Model] = [
            .init(
                title: "CommonNext".asLocalizedKey.uppercased(),
                action: { [weak self] button in
                    self?.next(button)
                },
                kind: .primary
            ),
            .init(
                title: backButtonTitle,
                action: { [weak self] button in
                    self?.cancel(button)
                },
                kind: .teritary
            ),
        ]
        
        return buttons
    }
    
    // MARK: Actions
    
    private func next(
        _ sender: JustonButton
    ) {
        guard let addressInput = formInput(at: IndexPath(item: 1, section: 0)),
              let amountInput = formInput(at: IndexPath(item: 2, section: 0))
        else {
            return
        }
        
        guard !addressInput.text.isEmpty
        else {
            addressInput.performErrorAnimation()
            return
        }
        
        guard let amount = Currency(value: amountInput.text), amount > 0
        else {
            amountInput.performErrorAnimation()
            return
        }
        
        let fromAccount = initialConfiguration.fromAccount
        let fromAddress = fromAccount.selectedContract.address
        let outAddress = addressInput.text
        
        let textMessage = formInput(at: IndexPath(item: 3, section: 0))?.text
        let messageBody = transferConfiguration?.payload
        let messageInitial = transferConfiguration?.initial
        
        sender.startAsynchronousOperation({ [weak self] in
            do {
                guard let displayableAddress = await DisplayableAddress(string: outAddress),
                      displayableAddress.concreteAddress.address != fromAddress
                else {
                    throw AddressError.unparsable
                }
                
                if !displayableAddress.concreteAddress.representation.flags.contains(.bounceable) && amount > 5_000_000_000 {
                    if let self = self {
                        let confirmation = UserConfirmation(.largeTransactionUnbouncableAddress, presentationContext: self)
                        do {
                            try await confirmation.confirm()
                        } catch {
                            throw ApplicationError.userCancelled
                        }
                    } else {
                        throw ApplicationError.userCancelled
                    }
                }
                
                let authentication = PasscodeAuthentication(inside: self!) // uhh
                let passcode = try await authentication.key()
                
                let message: Message
                if messageBody != nil || messageInitial != nil {
                    message = try await fromAccount.transfer(
                        to: displayableAddress.concreteAddress,
                        amount: amount,
                        message: (messageBody, messageInitial),
                        passcode: passcode
                    )
                } else {
                    message = try await fromAccount.transfer(
                        to: displayableAddress.concreteAddress,
                        amount: amount,
                        message: textMessage,
                        passcode: passcode
                    )
                }
                
                let fees = try await message.fees()
                let confimationViewController = await TransferConfirmationViewController(
                    initialConfiguration: .init(
                        fromAccount: fromAccount,
                        toAddress: displayableAddress,
                        amount: amount,
                        message: message,
                        estimatedFees: fees
                    )
                )
                
                await self?.show(confimationViewController, sender: nil)
            } catch AddressError.unparsable {
                await addressInput.performErrorAnimation()
            } catch is CancellationError {
            } catch ApplicationError.userCancelled {
            } catch {
                await self?.present(error)
            }
        })
    }
    
    private func cancel(
        _ sender: JustonButton
    ) {
        hide(animated: true)
    }
}

extension TransferDetailsViewController: CameraViewControllerDelegate {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeSchemeURL schemeURL: SchemeURL
    ) {
        viewController.hide(animated: true)
        switch schemeURL {
        case let .transfer(_, configuration):
            reload(
                using: configuration,
                isEditable: true,
                animatingDifferences: false
            )
        }
    }
}
