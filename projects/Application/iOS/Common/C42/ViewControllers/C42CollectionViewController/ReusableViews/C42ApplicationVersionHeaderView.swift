//
//  C42ApplicationVersionHeaderView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit

class C42ApplicationVersionHeaderView: UICollectionReusableView {
        
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .caption2)
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .center
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.text = "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))"
        
        backgroundColor = .hui_backgroundPrimary
        clipsToBounds = true
        
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: topAnchor, constant: 12)
            textLabel.pin(horizontally: self, left: 24, right: 24)
            bottomAnchor.pin(to: textLabel.bottomAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
