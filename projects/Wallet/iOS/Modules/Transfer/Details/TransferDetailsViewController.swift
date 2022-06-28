//
//  TransferDetailsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import SwiftyTON

class TransferDetailsViewController: UIViewController {
    
    private let errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.text = "TransferDetailsDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private lazy var destinationAddressView = BorderedTextView(caption: "CommonAddress".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .next
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 42
    })
    
    private lazy var amountTextView = BorderedTextView(caption: "CommonAmount".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .decimalPad
        $0.textView.returnKeyType = .next
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 42
    })
    
    private lazy var messageTextView = BorderedTextView(caption: "TransferDetailsMessageDescription".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .default
        $0.textView.returnKeyType = .default
        $0.textView.minimumContentSizeHeight = 64
        $0.textView.maximumContentSizeHeight = 128
    })
    
    private lazy var processButton = PrimaryButton(title: "CommonNext".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(nextButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CommonCancel".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private var destinationKeyboardConstraint: KeyboardLayoutConstraint?
    private var amountKeyboardConstraint: KeyboardLayoutConstraint?
    private var messageKeyboardConstraint: KeyboardLayoutConstraint?

    let initialConfiguration: InitialConfiguration
    
    private var outDestinationAddress: Address?
    private var outAmount: Currency?
    private var outMessage: String?
    
    private var prepareMessageTask: Task<(), Never>?
    
    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        prepareMessageTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TransferDetailsTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(destinationAddressView)
        view.addSubview(amountTextView)
        view.addSubview(messageTextView)
        view.addSubview(processButton)
        view.addSubview(cancelButton)
        
        destinationAddressView.textView.text = initialConfiguration.toAddress?.description ?? ""
        destinationAddressView.actions = [
            .init(
                image: .hui_scan20,
                block: { [weak self] in
                    self?.scanQRAndFill()
                }
            )
        ]
        textViewDidEndEditing(destinationAddressView.textView)
        
        amountTextView.textView.text = initialConfiguration.amount?.string(with: .maximum9) ?? ""
        textViewDidEndEditing(amountTextView.textView)
        
        messageTextView.textView.text = initialConfiguration.message ?? ""
        textViewDidEndEditing(messageTextView.textView)
        
        let destinationKeyboardConstraint = KeyboardLayoutConstraint(
            item: amountTextView,
            attribute: .top,
            relatedBy: .equal,
            toItem: destinationAddressView,
            attribute: .bottom,
            multiplier: 1,
            constant: 12
        )
        
        let amountKeyboardConstraint = KeyboardLayoutConstraint(
            item: messageTextView,
            attribute: .top,
            relatedBy: .equal,
            toItem: amountTextView,
            attribute: .bottom,
            multiplier: 1,
            constant: 12
        )
        
        let messageKeyboardConstraint = KeyboardLayoutConstraint(
            item: processButton,
            attribute: .top,
            relatedBy: .greaterThanOrEqual,
            toItem: messageTextView,
            attribute: .bottom,
            multiplier: 1,
            constant: 24
        )
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            destinationAddressView.topAnchor.pin(to: descriptionLabel.bottomAnchor, constant: 32)
            destinationAddressView.pin(horizontally: view, left: 16, right: 16)
            destinationKeyboardConstraint
            
            amountTextView.pin(horizontally: view, left: 16, right: 16)
            amountKeyboardConstraint
            
            messageTextView.pin(horizontally: view, left: 16, right: 16)
            messageKeyboardConstraint
            
            processButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: processButton.bottomAnchor, constant: 8)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })
        
        self.amountKeyboardConstraint = amountKeyboardConstraint
        self.destinationKeyboardConstraint = destinationKeyboardConstraint
        self.messageKeyboardConstraint = messageKeyboardConstraint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let navigationController = navigationController,
           navigationController.viewControllers.first == self
        {
            cancelButton.title = "CommonCancel".asLocalizedKey.uppercased()
        } else {
            cancelButton.title = "CommonBack".asLocalizedKey.uppercased()
        }
        
        if !destinationAddressView.textView.hasText {
            destinationAddressView.textView.becomeFirstResponder()
        } else if !amountTextView.textView.hasText {
            amountTextView.textView.becomeFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(false)
    }
    
    private func prepareMessageAndConfirm(
        outAddress: Address,
        amount: Currency,
        message: String?,
        sender: HuetonButton
    ) {
        let fromAccount = initialConfiguration.fromAccount
        sender.startAsynchronousOperation({ [weak self] in
            do {
                let authentication = PasscodeAuthentication(inside: self!) // uhh
                let passcode = try await authentication.key()
                
                let message = try await fromAccount.transfer(
                    to: outAddress,
                    amount: amount,
                    message: message,
                    passcode: passcode
                )
                
                let fees = try await message.fees()
                let confimationViewController = await TransferConfirmationViewController(
                    initialConfiguration: .init(
                        fromAccount: fromAccount,
                        toAddress: outAddress,
                        amount: amount,
                        message: message,
                        estimatedFees: fees
                    )
                )

                await self?.show(confimationViewController, sender: nil)
            } catch is CancellationError {
            } catch {
                await self?.present(error)
            }
        })
    }
    
    fileprivate func markTextViewAsError(_ textView: UITextView) {
        textView.superview?.shake()
        textView.textColor = .hui_letter_red
        errorFeedbackGenerator.impactOccurred()
    }
    
    // MARK: Actions
    
    private func scanQRAndFill() {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self
        
        let navigationController = NavigationController(rootViewController: qrViewController)
        hui_present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    private func nextButtonDidClick(_ sender: HuetonButton) {
        guard let address = outDestinationAddress
        else {
            markTextViewAsError(destinationAddressView.textView)
            return
        }
        
        guard let amout = outAmount
        else {
            markTextViewAsError(amountTextView.textView)
            return
        }
        
        var message = outMessage
        if let _message = message, _message.isEmpty {
            message = nil
        }
        
        prepareMessageAndConfirm(
            outAddress: address,
            amount: amout,
            message: message,
            sender: sender
        )
    }
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
}

extension TransferDetailsViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard processButton.operation == nil
        else {
            return false
        }
        
        destinationAddressView.setFocused(textView == destinationAddressView.textView)
        amountTextView.setFocused(textView == amountTextView.textView)
        messageTextView.setFocused(textView == messageTextView.textView)
        
        switch textView {
        case destinationAddressView.textView:
            destinationKeyboardConstraint?.bottomAnchor = .view(view: .init(amountTextView))
            amountKeyboardConstraint?.bottomAnchor = .none
            messageKeyboardConstraint?.bottomAnchor = .none
        case amountTextView.textView:
            destinationKeyboardConstraint?.bottomAnchor = .none
            amountKeyboardConstraint?.bottomAnchor = .view(view: .init(messageTextView))
            messageKeyboardConstraint?.bottomAnchor = .none
        case messageTextView.textView:
            destinationKeyboardConstraint?.bottomAnchor = .none
            amountKeyboardConstraint?.bottomAnchor = .none
            messageKeyboardConstraint?.bottomAnchor = .view(view: .init(processButton))
        default:
            break
        }
        
        textView.textColor = .white
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" && textView != messageTextView.textView
        else {
            return true
        }
        
        switch textView {
        case destinationAddressView.textView:
            amountTextView.textView.becomeFirstResponder()
        case amountTextView.textView:
            messageTextView.textView.becomeFirstResponder()
        case messageTextView.textView:
            break
        default:
            break
        }
        
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        (textView.superview as? BorderedTextView)?.setFocused(false)
        guard textView.hasText
        else {
            return
        }
        
        switch textView {
        case destinationAddressView.textView:
            guard let address = Address(string: textView.text),
                  address != Address(rawValue: initialConfiguration.fromAccount.selectedContract.address)
            else {
                markTextViewAsError(textView)
                return
            }
            outDestinationAddress = address
        case amountTextView.textView:
            guard let amount = Currency(value: textView.text),
                  amount > 0
            else {
                markTextViewAsError(textView)
                return
            }
            outAmount = amount
        case messageTextView.textView:
            outMessage = textView.text
        default:
            break
        }
    }
}

extension TransferDetailsViewController: CameraViewControllerDelegate {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeConvenienceURL convenienceURL: ConvenienceURL
    ) {
    
        viewController.hide(animated: true)
        
        switch convenienceURL {
        case let .transfer(destination, amount, text):
            destinationAddressView.textView.text = destination.description
            
            if let amount = amount {
                amountTextView.textView.text = amount.string(with: .maximum9)
            }
            
            if let text = text {
                messageTextView.textView.text = text
            }
        }
    }
}
