//
//  AccountAddingLabelCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import BilftUI

class AccountAddingLabelCell: UICollectionViewCell {
    
    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .bui_textPrimary
        $0.font = .font(for: .body)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .bui_backgroundPrimary
        contentView.addSubview(textLabel)
        
        textLabel.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
