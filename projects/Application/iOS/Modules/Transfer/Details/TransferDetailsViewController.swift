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
    
    private let imageView = UIImageView(image: .hui_placeholder512).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleToFill
    })
    
    private lazy var destinationAddressView = BorderedTextView(caption: "Address").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .next
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 42
    })
    
    private lazy var amountTextView = BorderedTextView(caption: "Amount").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .decimalPad
        $0.textView.returnKeyType = .next
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 42
    })
    
    private lazy var messageTextView = BorderedTextView(caption: "Message (optional)").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .default
        $0.textView.returnKeyType = .default
        $0.textView.minimumContentSizeHeight = 64
        $0.textView.maximumContentSizeHeight = 128
    })
    
    private lazy var processButton = PrimaryButton(title: "NEXT").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(nextButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CANCEL").with({
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
        
        title = "Transfer details"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(imageView)
        view.addSubview(destinationAddressView)
        view.addSubview(amountTextView)
        view.addSubview(messageTextView)
        
        view.addSubview(processButton)
        view.addSubview(cancelButton)
        
        
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
            relatedBy: .equal,
            toItem: messageTextView,
            attribute: .bottom,
            multiplier: 1,
            constant: 24
        )
        
        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 8)
            imageView.pin(horizontally: view, left: 16, right: 16)
            
            destinationAddressView.topAnchor.pin(greaterThan: imageView.bottomAnchor, constant: 24)
            destinationAddressView.pin(horizontally: view, left: 16, right: 16)
            destinationKeyboardConstraint
            
            amountTextView.pin(horizontally: view, left: 16, right: 16)
            amountKeyboardConstraint
            
            messageTextView.pin(horizontally: view, left: 16, right: 16)
            messageKeyboardConstraint
            
            processButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: processButton.bottomAnchor, constant: 12)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 0)
        })
        
        self.amountKeyboardConstraint = amountKeyboardConstraint
        self.destinationKeyboardConstraint = destinationKeyboardConstraint
        self.messageKeyboardConstraint = messageKeyboardConstraint
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
        let key = initialConfiguration.key
        
        sender.startAsynchronousOperation(operation: { [weak self] in
            do {
                let authentication = PasscodeAuthentication(inside: self!) // uhh
                let passcode = try await authentication.key()

                guard let wallet = try await Wallet3(rawAddress: fromAccount.selectedAddress.rawValue)
                else {
                    throw SwiftyTON.ContractError.unknownContractType
                }

                let message = try await wallet.transfer(
                    to: outAddress,
                    amount: amount,
                    message: message,
                    key: key,
                    passcode: passcode
                )

                let confimationViewController = await TransferConfirmationViewController(
                    initialConfiguration: .init(
                        fromAccount: fromAccount,
                        toAddress: outAddress,
                        amount: amount,
                        message: message
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
        textView.shake()
        textView.textColor = .hui_letter_red
        errorFeedbackGenerator.impactOccurred()
    }
    
    // MARK: Actions
    
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
        dismiss(animated: true)
    }
}

extension TransferDetailsViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
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
        guard textView.hasText
        else {
            return
        }
        
        switch textView {
        case destinationAddressView.textView:
            guard let address = Address(string: textView.text),
                  address != initialConfiguration.fromAccount.selectedAddress
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
