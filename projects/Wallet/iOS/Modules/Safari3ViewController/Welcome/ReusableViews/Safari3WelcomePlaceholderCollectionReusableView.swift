//
//  Safari3WelcomePlaceholderCollectionReusableView.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import HuetonUI

class Safari3WelcomePlaceholderCollectionReusableView: UICollectionReusableView {
    
    static let estimatedHeight: CGFloat = 256
        
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.text = "Safari3FavouritesEmptyTitle".asLocalizedKey
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let button = SecondaryButton(title: "Safari3FavouritesEmptyButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    var action: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hui_backgroundPrimary
        
        addSubview(textLabel)
        addSubview(button)
        
        button.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: topAnchor, constant: 48)
            textLabel.pin(horizontally: self, left: 36, right: 36)
            
            button.topAnchor.pin(to: textLabel.bottomAnchor, constant: 24)
            button.pin(horizontally: self, left: 36, right: 36)
            
            bottomAnchor.pin(greaterThan: button.bottomAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    @objc
    private func buttonDidClick(_ sender: UIControl) {
        action?()
    }
}
