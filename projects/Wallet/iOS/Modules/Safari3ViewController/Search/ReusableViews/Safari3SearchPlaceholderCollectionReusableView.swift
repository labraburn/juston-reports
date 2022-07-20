//
//  Safari3SearchPlaceholderCollectionReusableView.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit
import JustonUI

class Safari3SearchPlaceholderCollectionReusableView: UICollectionReusableView {
    
    static let estimatedHeight: CGFloat = 256
        
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.textColor = .jus_textPrimary
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .jus_backgroundPrimary
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: topAnchor, constant: 48)
            textLabel.pin(horizontally: self, left: 36, right: 36)
            bottomAnchor.pin(greaterThan: textLabel.bottomAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
