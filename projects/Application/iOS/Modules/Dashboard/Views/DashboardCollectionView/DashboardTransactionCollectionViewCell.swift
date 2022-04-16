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
    
    static let absoluteHeight: CGFloat = 66
    
    var model: Model? {
        didSet {
            guard model != oldValue, let model = model
            else {
                return
            }
            
            update(model: model)
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
        
        contentView.backgroundColor = .hui_backgroundSecondary
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        
        contentView.addSubview(imageView)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(addressLabel)
        
        NSLayoutConstraint.activate({
            imageView.leftAnchor.pin(to: contentView.leftAnchor, constant: 16)
            imageView.centerYAnchor.pin(to: contentView.centerYAnchor)
            
            balanceLabel.topAnchor.pin(to: contentView.topAnchor, constant: 12)
            balanceLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 12)
            rightAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            
            addressLabel.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 6)
            addressLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 12)
            rightAnchor.pin(to: addressLabel.rightAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(model: Model) {
        guard let account = model.account
        else {
            return
        }
        
        balanceLabel.text = Self.balanceFormatter.string(from: model.value)
        
        if model.fromAddress == account.rawAddress {
            imageView.image = .hui_sendColor24
            balanceLabel.textColor = .hui_letter_red
            
            if let toAddressRaw = model.toAddresses.first {
                let toAddress = Address(rawAddress: toAddressRaw)
                let addressURL = toAddress.convert(representation: .base64url(flags: []))
                addressLabel.text = "to \(addressURL)"
            } else {
                addressLabel.text = "to ..."
            }
        } else {
            imageView.image = .hui_receiveColor24
            balanceLabel.textColor = .hui_letter_green
            
            let fromAddress = Address(rawAddress: model.fromAddress)
            let addressURL = fromAddress.convert(representation: .base64url(flags: []))
            addressLabel.text = "from \(addressURL)"
        }
    }
}
