//
//  C42LogoHeaderView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class C42LogoHeaderView: UICollectionReusableView {
    
    let huetonView = HuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.pin(to: 20).isActive = true
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        huetonView.performUpdatesWithLetters({ $0.on() })
        
        backgroundColor = .hui_backgroundPrimary
        clipsToBounds = true
        
        addSubview(huetonView)
        
        NSLayoutConstraint.activate({
            huetonView.topAnchor.pin(to: topAnchor, constant: 16)
            huetonView.centerXAnchor.pin(to: centerXAnchor)
            bottomAnchor.pin(to: huetonView.bottomAnchor, constant: 12)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
