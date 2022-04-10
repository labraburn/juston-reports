//
//  SteppableWordCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class SteppableWordCell: UICollectionViewCell {
    
    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .headline)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.heightAnchor.pin(to: 36).isActive = true
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .hui_backgroundSecondary
        contentView.addSubview(textLabel)
        
        textLabel.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
