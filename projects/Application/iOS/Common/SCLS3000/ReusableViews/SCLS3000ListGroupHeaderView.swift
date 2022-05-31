//
//  SCLS3000ListGroupHeaderView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

class SCLS3000ListGroupHeaderView: UICollectionReusableView {
        
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .caption1)
        $0.textColor = .hui_textSecondary
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hui_backgroundPrimary
        clipsToBounds = true
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate({
            titleLabel.pin(edges: self)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
