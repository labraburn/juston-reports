//
//  CardStackCardLargeContentView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

final class CardStackCardContentLargeView: CardStackCardContentView {
    
    static let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 9
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    private let accountNameLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let accountCurrentAddressLabel = VerticalLabelContainerView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.label.lineBreakMode = .byTruncatingMiddle
        $0.label.numberOfLines = 1
        $0.label.textAlignment = .center
    })
    
    private let balanceLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.numberOfLines = 2
    })
    
    private let bottomButtonsHStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 16
        $0.clipsToBounds = false
    })
    
    private let sendButton = CardStackCardButton.createBottomButton(.hui_send24)
    private let receiveButton = CardStackCardButton.createBottomButton(.hui_receive24)
    private let moreButton = CardStackCardButton.createBottomButton(.hui_more24)
    
    override init(model: CardStackCard) {
        super.init(model: model)
        
        addSubview(accountNameLabel)
        addSubview(moreButton)
        addSubview(accountCurrentAddressLabel)

        addSubview(balanceLabel)
        addSubview(bottomButtonsHStackView)
        bottomButtonsHStackView.addArrangedSubview(sendButton)
        bottomButtonsHStackView.addArrangedSubview(receiveButton)
        bottomButtonsHStackView.addArrangedSubview(moreButton)
        
        sendButton.addTarget(self, action: #selector(sendButtonDidClick(_:)), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveButtonDidClick(_:)), for: .touchUpInside)
        
        moreButton.showsMenuAsPrimaryAction = true
        
        NSLayoutConstraint.activate({
            accountNameLabel.topAnchor.pin(to: topAnchor, constant: 23)
            accountNameLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountCurrentAddressLabel.leftAnchor.pin(to: accountNameLabel.rightAnchor, constant: 12)
            accountNameLabel.heightAnchor.pin(to: 33)
            
            accountCurrentAddressLabel.topAnchor.pin(to: topAnchor, constant: 20)
            accountCurrentAddressLabel.widthAnchor.pin(to: 16)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 20)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 22)
            
            balanceLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountCurrentAddressLabel.leftAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            
            bottomButtonsHStackView.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 30)
            bottomButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 20)
            bottomButtonsHStackView.heightAnchor.pin(to: 52)
            bottomButtonsHStackView.widthAnchor.pin(greaterThan: 128)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: bottomButtonsHStackView.rightAnchor, constant: 12, priority: .required - 1)
            bottomAnchor.pin(to: bottomButtonsHStackView.bottomAnchor, constant: 24)
            
            sendButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            receiveButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            moreButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
        })
        
        reload()
    }
    
    override func reload() {
        super.reload()
        
        let tintColor = UIColor(rgba: model.account.appearance.tintColor)
        let controlsForegroundColor = UIColor(rgba: model.account.appearance.controlsForegroundColor)
        let controlsBackgroundColor = UIColor(rgba: model.account.appearance.controlsBackgroundColor)
        
        sendButton.tintColor = controlsForegroundColor
        sendButton.backgroundColor = controlsBackgroundColor
        receiveButton.tintColor = controlsForegroundColor
        receiveButton.backgroundColor = controlsBackgroundColor
        moreButton.tintColor = controlsForegroundColor
        moreButton.backgroundColor = controlsBackgroundColor
        
        let name = model.account.name
        let address = Address(rawAddress: model.account.rawAddress)
            .convert(representation: .base64url(flags: [.bounceable]))
        
        accountNameLabel.textColor = tintColor
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.label.textColor = tintColor.withAlphaComponent(0.3)
        accountCurrentAddressLabel.label.attributedText = .string(address, with: .callout)
        
        let balance = model.account.balance
        let balances = (Self.balanceFormatter.string(from: balance) ?? "0.0").components(separatedBy: ".")
        
        balanceLabel.textColor = tintColor
        balanceLabel.attributedText = NSMutableAttributedString().with({
            $0.append(NSAttributedString(string: balances[0], attributes: [
                .font : UIFont.monospacedSystemFont(ofSize: 57, weight: .bold),
                .paragraphStyle : NSMutableParagraphStyle().with({
                    $0.minimumLineHeight = 57
                    $0.maximumLineHeight = 57
                })
            ]))
            $0.append(.string("\n." + balances[1], with: .body, kern: .four, lineHeight: 17))
        })
        
        moreButton.menu = nil
        moreButton.menu = more()
    }
}
