//
//  TransactionsTransactionCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import JustonUI
import JustonCORE

class TransactionsTransactionCollectionViewCell: UICollectionViewCell {
    
    struct Model: Hashable {
        
        enum Kind {
            
            case `in`
            case out
            case pending
        }
        
        let kind: Kind
        let from: ConcreteAddress?
        let to: [ConcreteAddress]
        let value: Currency
    }
    
    static let absoluteHeight: CGFloat = 51
    
    var model: Model? {
        didSet {
            guard model != oldValue, let model = model
            else {
                return
            }
            
            update(model: model)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setHighlightedAnimated(isHighlighted)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
               impactOccurred()
            }
        }
    }
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let loadingView = OverlayLoadingView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.cornerRadius = 12
    })
    
    private let addressLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .caption1)
        $0.textColor = .jus_textSecondary
        $0.lineBreakMode = .byTruncatingMiddle
    })
    
    private let balanceLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.textColor = .jus_textSecondary
        $0.lineBreakMode = .byTruncatingMiddle
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator()
        insertHighlightingScaleAnimation()
        
        contentView.backgroundColor = .jus_backgroundPrimary
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        
        contentView.addSubview(imageView)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(addressLabel)
        
        NSLayoutConstraint.activate({
            imageView.leftAnchor.pin(to: contentView.leftAnchor, constant: 0)
            imageView.pin(vertically: contentView)
            imageView.widthAnchor.pin(to: imageView.heightAnchor)
            
            balanceLabel.topAnchor.pin(to: contentView.topAnchor, constant: 4)
            balanceLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 10)
            rightAnchor.pin(to: balanceLabel.rightAnchor, constant: 0)
            
            addressLabel.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 6)
            addressLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 10)
            rightAnchor.pin(to: addressLabel.rightAnchor, constant: 0)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(model: Model) {
        let value = CurrencyFormatter.string(from: model.value, options: .maximum9)
        switch model.kind {
        case .in:
            imageView.image = .jus_receiveColor51
            
            if let from = model.from {
                addressLabel.text = "from \(from.description)"
            } else {
                addressLabel.text = "from ..."
            }
            
            balanceLabel.text = "\(value)"
            balanceLabel.textColor = .jus_letter_green
        case .out:
            imageView.image = .jus_sendColor51
            
            if let to = model.to.first { // TODO: Fixme and show all addresses
                addressLabel.text = "to \(to.description)"
            } else {
                addressLabel.text = "to ..."
            }
            
            balanceLabel.text = "\(value)"
            balanceLabel.textColor = .jus_letter_red
        case .pending:
            imageView.image = .jus_sendColor51
            
            if let to = model.to.first { // TODO: Fixme and show all addresses
                addressLabel.text = "to \(to.description)"
            } else {
                addressLabel.text = "to ..."
            }
            
            balanceLabel.text = "\(value)"
            balanceLabel.textColor = .jus_textPrimary
        }
        
        startLoadingAnimationIfNeeded(model: model)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        loadingView.removeFromSuperview()
        loadingView.stopAnimation(completion: nil)
    }
    
    private func startLoadingAnimationIfNeeded(model: Model) {
        switch model.kind {
        case .pending:
            if loadingView.superview == nil {
                contentView.addSubview(loadingView)
                NSLayoutConstraint.activate({
                    loadingView.leftAnchor.pin(to: contentView.leftAnchor, constant: 0)
                    loadingView.pin(vertically: contentView)
                    loadingView.widthAnchor.pin(to: imageView.heightAnchor)
                })
            }
            loadingView.startAnimation(delay: 0)
        case .in, .out:
            loadingView.removeFromSuperview()
            loadingView.stopAnimation(completion: nil)
        }
    }
}
