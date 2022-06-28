//
//  AccountStackLogotypeNavigationView.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import HuetonUI

class AccountStackLogotypeNavigationView: UIStackView {
    
    let logotypeView = AccountStackLogotypeView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let leftButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -12)
        $0.tintColor = .hui_textPrimary
    })
    
    let rightButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -12)
        $0.tintColor = .hui_textPrimary
    })

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        backgroundColor = .clear
        
        axis = .horizontal
        alignment = .top
        distribution = .equalCentering
        sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -24)
        backgroundColor = .hui_backgroundPrimary
        
        addArrangedSubview(leftButton)
        addArrangedSubview({
            let touchAreaInsets = UIEdgeInsets(top: -24, left: 0, right: 0, bottom: -24)
            let wrapperView = UIView()
            wrapperView.addSubview(logotypeView)
            wrapperView.heightAnchor.pin(to: HuetonView.applicationHeight).isActive = true
            logotypeView.pinned(edges: wrapperView)
            
            wrapperView.sui_touchAreaInsets = touchAreaInsets
            logotypeView.sui_touchAreaInsets = touchAreaInsets
            
            return wrapperView
        }())
        addArrangedSubview(rightButton)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
