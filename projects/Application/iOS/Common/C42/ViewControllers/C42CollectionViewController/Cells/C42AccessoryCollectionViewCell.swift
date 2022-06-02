//
//  C42AccessoryCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

class C42AccessoryCollectionViewCell: UICollectionViewCell {
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var textAligment: NSTextAlignment = .left {
        didSet {
            textLabel.textAlignment = textAligment
        }
    }
    
    var numberOfLines: Int = 1 {
        didSet {
            textLabel.numberOfLines = numberOfLines
            
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator(style: .light)
        insertHighlightingAlphaAnimation()
        
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            textLabel.pin(edges: contentView)
            contentView.heightAnchor.pin(greaterThan: 24)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            setHighlightedAnimated(isHighlighted)
            if isHighlighted {
               impactOccurred()
            }
        }
    }
}
