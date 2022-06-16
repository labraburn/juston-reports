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
    
    var action: (() -> ())? = nil
    
    let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.pin(to: 128).isActive = true
        $0.widthAnchor.pin(to: 128).isActive = true
        $0.image = .hui_appIcon128
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hui_backgroundPrimary
        clipsToBounds = true
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: topAnchor)
            imageView.centerXAnchor.pin(to: centerXAnchor)
            bottomAnchor.pin(to: imageView.bottomAnchor)
        })
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 3
        tapGestureRecognizer.addTarget(self, action: #selector(tapGestureRecognizerDidAction(_:)))
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    @objc
    private func tapGestureRecognizerDidAction(_ sender: UITapGestureRecognizer) {
        action?()
    }
}
