//
//  Safari3BrowserErrorView.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import JustonUI

class Safari3BrowserErrorView: UIView {
    
    struct Model {
        
        let text: String
        let action: (() -> ())?
    }
    
    private let stackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 24
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.textColor = .jus_textPrimary
        $0.font = .font(for: .body)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private let buttonWrapper = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let actionButton = SecondaryButton(title: "Safari3ErrorButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    var model: Model? {
        didSet {
            textLabel.text = model?.text
            buttonWrapper.isHidden = model?.action == nil
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    init() {
        super.init(
            frame: .zero
        )
        
        buttonWrapper.addSubview(actionButton)
        
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(buttonWrapper)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate({
            stackView.topAnchor.pin(greaterThan: safeAreaLayoutGuide.topAnchor, constant: 42, priority: .defaultLow)
            stackView.pin(horizontally: self, left: 16, right: 16)
            stackView.centerYAnchor.pin(to: centerYAnchor)
            bottomAnchor.pin(lessThan: stackView.bottomAnchor, constant: 42, priority: .defaultLow)
            
            actionButton.pin(
                edges: buttonWrapper,
                insets: UIEdgeInsets(
                    left: 36,
                    right: 36
                )
            )
        })
        
        actionButton.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    @objc
    private func buttonDidClick(_ sender: UIControl) {
        model?.action?()
    }
}
