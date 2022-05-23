//
//  CardStackCardCompactContentView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

final class CardStackCardContentCompactView: CardStackCardContentView {
    
    private let accountNameLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let accountCurrentAddressLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.lineBreakMode = .byTruncatingMiddle
        $0.numberOfLines = 1
        $0.textAlignment = .center
    })
    
    private let moreButton = UIButton(type: .system).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .medium)
        $0.setImage(.hui_more24, for: .normal)
    })
    
    override init(model: CardStackCard) {
        super.init(model: model)
        
        addSubview(accountNameLabel)
        addSubview(accountCurrentAddressLabel)
        addSubview(moreButton)
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = more()
        
        NSLayoutConstraint.activate({
            accountNameLabel.topAnchor.pin(to: topAnchor, constant: 18)
            accountNameLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountNameLabel.heightAnchor.pin(to: 33)
            
            moreButton.leftAnchor.pin(to: accountNameLabel.rightAnchor, constant: 8)
            moreButton.topAnchor.pin(to: topAnchor, constant: 21)
            rightAnchor.pin(to: moreButton.rightAnchor, constant: 16)
            
            accountCurrentAddressLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountCurrentAddressLabel.heightAnchor.pin(to: 29)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 12)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 20)
        })
        
        reload()
    }
    
    override func reload() {
        super.reload()
        
        let name = model.account.name
        let address = model.account.selectedAddress.convert(to: .base64url(flags: []))
        let tintColor = UIColor(rgba: model.account.appearance.tintColor)
        
        accountNameLabel.textColor = tintColor
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.textColor = tintColor.withAlphaComponent(0.3)
        accountCurrentAddressLabel.attributedText = .string(address, with: .callout)
        
        moreButton.tintColor = tintColor
        moreButton.menu = nil
        moreButton.menu = more()
    }
}
