//
//  DashboardTransactionCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import DeclarativeUI

class DashboardTransactionCollectionViewCell: UICollectionViewCell {
    
    static let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 9
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    typealias Model = PersistenceTransaction
    
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
            if isHighlighted {
               impactOccurred()
            }
        }
    }
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let addressLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .caption1)
        $0.textColor = .hui_textSecondary
        $0.lineBreakMode = .byTruncatingMiddle
    })
    
    private let balanceLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.textColor = .hui_textSecondary
        $0.lineBreakMode = .byTruncatingMiddle
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator()
        insertHighlightingScaleAnimation()
        
        contentView.backgroundColor = .hui_backgroundPrimary
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
        if model.toAddresses.count == 1, model.fromAddress == model.toAddresses.first {
            imageView.image = .hui_sendColor51
            
            balanceLabel.text = "\(Self.balanceFormatter.string(from: model.value) ?? "")"
            balanceLabel.textColor = .hui_letter_red
            
            if let toAddressRaw = model.toAddresses.first {
                let toAddress = Address(rawValue: toAddressRaw)
                let addressURL = toAddress.convert(representation: .base64url(flags: []))
                addressLabel.text = "to \(addressURL)"
            } else {
                addressLabel.text = "to ..."
            }
        } else if model.fromAddress == model.account.selectedAddress.rawValue {
            imageView.image = .hui_sendColor51
            
            balanceLabel.text = "-\(Self.balanceFormatter.string(from: model.value) ?? "")"
            balanceLabel.textColor = .hui_letter_red
            
            if let toAddressRaw = model.toAddresses.first {
                let toAddress = Address(rawValue: toAddressRaw)
                let addressURL = toAddress.convert(representation: .base64url(flags: []))
                addressLabel.text = "to \(addressURL)"
            } else {
                addressLabel.text = "to ..."
            }
        } else {
            imageView.image = .hui_receiveColor51
            
            balanceLabel.text = "+\(Self.balanceFormatter.string(from: model.value) ?? "")"
            balanceLabel.textColor = .hui_letter_green
            
            let fromAddress = Address(rawValue: model.fromAddress)
            let addressURL = fromAddress.convert(representation: .base64url(flags: []))
            addressLabel.text = "from \(addressURL)"
        }
    }
}
