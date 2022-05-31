//
//  InAppAnnouncementView.swift
//  iOS
//
//  Created by Anton Spivak on 29.04.2022.
//

import UIKit
import DeclarativeUI

final class InAppAnnouncementView: UIView {
    
    let inAppAnnouncement: InAppAnnouncementWindow.InAppAnnouncement
    var touchHandler: () -> () = {}
    
    private let tintView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundSecondary.withAlphaComponent(0.04)
        $0.clipsToBounds = true
    })
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(radius: 48)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    })
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .center
    })
    
    private let textLabel = UILabel().with({
        $0.textColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    })
    
    init(inAppAnnouncement: InAppAnnouncementWindow.InAppAnnouncement) {
        self.inAppAnnouncement = inAppAnnouncement
        
        super.init(frame: .zero)
        backgroundColor = .clear
        
        visualEffectView.layer.borderColor = UIColor(rgb: 0x353535).cgColor
        visualEffectView.layer.borderWidth = 1
        
        imageView.tintColor = inAppAnnouncement.tintColor
        
        addSubview(tintView)
        addSubview(visualEffectView)
        
        imageView.image = inAppAnnouncement.image
        textLabel.attributedText = inAppAnnouncement.attributedString
        
        addSubview(imageView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            tintView.pin(edges: self)
            visualEffectView.pin(edges: self)
            
            textLabel.pin(vertically: self, top: 12, bottom: 12)
            textLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 8)
            rightAnchor.pin(to: textLabel.rightAnchor, constant: 16)
            
            imageView.leftAnchor.pin(to: leftAnchor, constant: 16)
            imageView.centerYAnchor.pin(to: textLabel.centerYAnchor)
            imageView.widthAnchor.pin(to: 42)
            imageView.heightAnchor.pin(to: 42)
            
            heightAnchor.pin(greaterThan: 64)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        visualEffectView.layer.cornerRadius = bounds.height / 2
        visualEffectView.layer.cornerCurve = .continuous
        
        tintView.layer.cornerRadius = bounds.height / 2
        tintView.layer.cornerCurve = .continuous
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
        layer.shadowColor = UIColor(rgb: 0x000000).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        layer.shadowRadius = 24
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchHandler()
    }
}
