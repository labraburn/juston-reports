//
//  C42WordCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import JustonUI

class C42WordCell: UICollectionViewCell {
    
    struct Model {
        
        let index: Int
        let word: String
    }
    
    var model: Model? = nil {
        didSet {
            guard let model = model
            else {
                textLabel.text = nil
                return
            }
            
            textLabel.attributedText = NSMutableAttributedString({
                NSAttributedString("\(model.index).", with: .caption2, foregroundColor: .jus_textSecondary)
                NSAttributedString("\(model.word)", with: .headline, foregroundColor: .jus_textPrimary)
            })
        }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .jus_textPrimary
        $0.font = .font(for: .subheadline)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.heightAnchor.pin(to: 24).isActive = true
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .jus_backgroundSecondary
        contentView.addSubview(textLabel)
        
        textLabel.pinned(
            edges: contentView,
            insets: UIEdgeInsets(top: 8, left: 14, right: 14, bottom: 8)
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
    }
}
