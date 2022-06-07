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
import DeclarativeUI

class TransferConfirmationViewController: UIViewController {
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.text = "Please, review transfer details and then press send if it's correct"
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.numberOfLines = 0
    })
    
    private lazy var processButton = PrimaryButton(title: "CommonSend".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(processButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CommonBack".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })
    
    let initialConfiguration: InitialConfiguration
    
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
        
        title = "TransferConformationTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(textLabel)
        view.addSubview(processButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            textLabel.topAnchor.pin(to: descriptionLabel.bottomAnchor, constant: 32)
            textLabel.pin(horizontally: view, left: 16, right: 16)
            
            processButton.topAnchor.pin(greaterThan: textLabel.bottomAnchor, constant: 12)
            processButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: processButton.bottomAnchor, constant: 8)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })
        
        let spacing = NSAttributedString(" \n", with: .body, lineHeight: 6)
        textLabel.attributedText = NSMutableAttributedString({
            NSAttributedString("\("TransferDestinationAddress".asLocalizedKey):", with: .subheadline, foregroundColor: .hui_textSecondary)
            spacing
            NSAttributedString("\(initialConfiguration.toAddress)\n\n", with: .body)
            
            NSAttributedString("\("TransferDestinationAmount".asLocalizedKey):", with: .subheadline, foregroundColor: .hui_textSecondary)
            spacing
            NSAttributedString("\(initialConfiguration.amount.string(with: .maximum9))\n\n", with: .body)
            
            NSAttributedString("\("TransferDestinationEstimatedFees".asLocalizedKey):", with: .subheadline, foregroundColor: .hui_textSecondary)
            spacing
            NSAttributedString("\(initialConfiguration.estimatedFees.string(with: .maximum9))\n\n", with: .body)
        })
    }
    
    // MARK: Actions
    
    @objc
    private func processButtonDidClick(_ sender: HuetonButton) {
        let initialConfiguration = initialConfiguration
        let accoundID = initialConfiguration.fromAccount.objectID
        let message = initialConfiguration.message
        
        sender.startAsynchronousOperation({ [weak self] in
            do {
                let account = await PersistenceAccount.writeableObject(id: accoundID)

                try await message.send()
                try await PersistencePendingTransaction(
                    account: account,
                    destinationAddress: initialConfiguration.toAddress,
                    value: initialConfiguration.amount,
                    estimatedFees: initialConfiguration.estimatedFees,
                    body: initialConfiguration.message.body.data,
                    bodyHash: initialConfiguration.message.bodyHash
                ).save()
            } catch is CancellationError {
            } catch {
                await self?.present(error)
            }
            
            await self?.hide(animated: true, popIfAvailable: false)
        })
    }
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
}

