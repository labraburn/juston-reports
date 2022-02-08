//
//  DashboardWalletCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import SwiftyTON
import BilftUI

class DashboardWalletCollectionViewCell: UICollectionViewCell {
    
    static let absoluteHeight: CGFloat = 164
    
    private var state: [NSLayoutConstraint] = []
    
    private let addressLabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .bui_textPrimary
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.lineBreakMode = .byTruncatingMiddle
    }
    
    private let balanceLabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .bui_textPrimary
        $0.font = .systemFont(ofSize: 42, weight: .medium)
    }
    
    func fill(with wallet: Wallet) {
        addressLabel.text = "Address: \(wallet.address)"
        balanceLabel.text = "\(wallet.info.balance) TON"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(named: "BackgroundSecondary")
        
        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(addressLabel)
        contentView.addSubview(balanceLabel)
        
        NSLayoutConstraint.activate {
            addressLabel.topAnchor.pin(to: contentView.topAnchor, constant: 12)
            addressLabel.heightAnchor.pin(to: 24)
            addressLabel.pin(horizontally: contentView, left: 12, right: 12)
            
            balanceLabel.pin(horizontally: contentView, left: 12, right: 12)
            bottomAnchor.pin(to: balanceLabel.bottomAnchor, constant: 12)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
