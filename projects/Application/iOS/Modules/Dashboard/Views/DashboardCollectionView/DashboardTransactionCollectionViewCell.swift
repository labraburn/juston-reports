//
//  DashboardTransactionCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import UIKit
import HuetonUI
import SwiftyTON
import DeclarativeUI

class DashboardTransactionCollectionViewCell: UICollectionViewCell {
    
    typealias Model = Transaction
    
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
    
    private let leftVStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 8
    })
    
    private let leftTopLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
    })
    
    private let leftBottomLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
    })
    
    private let rightVStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 8
    })
    
    private let rightTopLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
    })
    
    private let rightBottomLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.lineBreakMode = .byTruncatingMiddle
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .hui_backgroundSecondary
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
    
        contentView.addSubview(leftVStackView)
        leftVStackView.addArrangedSubview(leftTopLabel)
        leftVStackView.addArrangedSubview(leftBottomLabel)
        
        contentView.addSubview(rightVStackView)
        rightVStackView.addArrangedSubview(rightTopLabel)
        rightVStackView.addArrangedSubview(rightBottomLabel)
        
        NSLayoutConstraint.activate({
            leftVStackView.pin(vertically: contentView, top: 12, bottom: 12)
            leftVStackView.leftAnchor.pin(to: contentView.leftAnchor, constant: 12)
            
            rightVStackView.pin(vertically: contentView, top: 12, bottom: 12)
            rightVStackView.leftAnchor.pin(to: leftVStackView.rightAnchor, constant: 12)
            rightAnchor.pin(to: rightVStackView.rightAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(model: Model) {
        if let message = model.out.first {
            // sended

            // TODO: Here can be more than one message, so we should handle it

            leftTopLabel.text = "Sended:"
            leftBottomLabel.text = "To:"

            rightTopLabel.textColor = .systemRed
            rightTopLabel.text = "\(message.value)"

            if let rawAddress = message.destinationAccountAddress {
                let address = Address(rawAddress: rawAddress)
                rightBottomLabel.text = address.convert(representation: .base64url(flags: []))
            } else {
                rightBottomLabel.text = " "
            }
        } else if let message = model.in {
            // received
            
            leftTopLabel.text = "Received:"
            leftBottomLabel.text = "From:"
            
            rightTopLabel.textColor = .systemGreen
            rightTopLabel.text = "\(message.value)"
            
            if let rawAddress = message.sourceAccountAddress {
                let address = Address(rawAddress: rawAddress)
                rightBottomLabel.text = address.convert(representation: .base64url(flags: []))
            } else {
                rightBottomLabel.text = " "
            }
            
        } else {
            leftTopLabel.text = " "
            leftBottomLabel.text = " "
            
            rightTopLabel.text = " "
            rightBottomLabel.text = " "
        }
    }
}
