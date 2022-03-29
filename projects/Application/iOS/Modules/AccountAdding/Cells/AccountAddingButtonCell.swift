//
//  AccountAddingButtonCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class AccountAddingButtonCell: UICollectionViewCell {
    
    var title: String? {
        get { textLabel.attributedText?.string }
        set { textLabel.attributedText = .string(newValue, with: .headline, kern: .four) }
    }
    
    var kind: AccountAddingItem.ButtonKind = .primary {
        didSet {
            switch kind {
            case .primary:
                contentView.layer.borderWidth = 0
                contentView.layer.borderColor = nil
                contentView.backgroundColor = UIColor(rgb: 0x4AB1FF)
            case .secondary:
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor(rgb: 0x4AB1FF).cgColor
                contentView.backgroundColor = nil
            }
            contentView.layer.cornerCurve = .continuous
            contentView.layer.cornerRadius = 16
        }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.heightAnchor.pin(to: 52).isActive = true
    })
    
    override var isHighlighted: Bool {
        didSet {
            setScaledDown(isHighlighted)
            if isHighlighted {
               impactOccurred()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator()
        insertHighlightingScaleDownAnimation()
        
        contentView.addSubview(textLabel)
        textLabel.pinned(edges: contentView)
        
        kind = .primary
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
