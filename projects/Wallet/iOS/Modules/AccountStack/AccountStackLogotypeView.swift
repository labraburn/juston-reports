//
//  AccountStackLogotypeView.swift
//  iOS
//
//  Created by Anton Spivak on 23.06.2022.
//

import UIKit
import HuetonUI

final class AccountStackLogotypeView: UIControl {
    
    let huetonView = HuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
    })
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        addSubview(huetonView)
        huetonView.pinned(edges: self)
        
        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .light)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
