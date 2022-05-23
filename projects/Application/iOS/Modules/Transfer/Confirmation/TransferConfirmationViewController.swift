//
//  TransferConfirmationViewController.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import SwiftyTON

class TransferConfirmationViewController: UIViewController {
    
    private let imageView = UIImageView(image: .hui_placeholder512).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.setContentCompressionResistancePriority(.required - 1, for: .vertical)
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.numberOfLines = 0
    })
    
    private lazy var processButton = PrimaryButton(title: "PROCESS").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(processButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CANCEL").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private var infinityFeesTask: Task<(), Never>?
    
    let initialConfiguration: InitialConfiguration
    
    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        infinityFeesTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Confirm transfer"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(processButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 8)
            imageView.pin(horizontally: view, left: 16, right: 16)
            
            textLabel.topAnchor.pin(to: imageView.bottomAnchor, constant: 12)
            textLabel.pin(horizontally: view, left: 16, right: 16)
            
            processButton.topAnchor.pin(greaterThan: textLabel.bottomAnchor, constant: 12)
            processButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: processButton.bottomAnchor, constant: 12)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 0)
        })
        
        updateTextLabel()
        
        let message = initialConfiguration.message
        infinityFeesTask = Task.detachedInfinityLoop(
            delay: 5,
            operation: { [weak self] in
                let fees = try await message.fees()
                await self?.updateTextLabel(fees: fees)
            }
        )
    }
    
    private func updateTextLabel(fees: Currency? = nil) {
        let string = NSMutableAttributedString()
        string.append(.string("Address: ", with: .body, kern: .default))
        string.append(.string("\(initialConfiguration.toAddress)", with: .body, kern: .four))
        
        string.append(.init(string: "\n\n"))
        
        string.append(.string("Value: ", with: .body, kern: .default))
        string.append(.string("\(initialConfiguration.amount.string(with: .maximum9))", with: .body, kern: .four))
        
        string.append(.init(string: "\n\n"))
        
        string.append(.string("Estimated fees: ", with: .body, kern: .default))
        if let fees = fees?.string(with: .maximum9) {
            string.append(.string("\(fees)", with: .body, kern: .four))
        } else {
            string.append(.string("...", with: .body, kern: .four))
        }
        
        textLabel.attributedText = string
    }
    
    private func finish() {
        infinityFeesTask?.cancel()
        dismiss(animated: true)
    }
    
    // MARK: Actions
    
    @objc
    private func processButtonDidClick(_ sender: HuetonButton) {
        let initialConfiguration = initialConfiguration
        let accoundID = initialConfiguration.fromAccount.objectID
        let message = initialConfiguration.message
        
        sender.startAsynchronousOperation(operation: { [weak self] in
            do {
                let account = await PersistenceAccount.writeableObject(id: accoundID)
                
                try await message.send()
                try await PersistencePendingTransaction(
                    account: account,
                    destinationAddress: initialConfiguration.toAddress,
                    value: initialConfiguration.amount,
                    estimatedFees: Currency(value: 0),
                    body: initialConfiguration.message.body.data,
                    bodyHash: initialConfiguration.message.bodyHash
                ).save()
            } catch is CancellationError {
            } catch {
                await self?.present(error)
            }
            
            await self?.finish()
        })
    }
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

