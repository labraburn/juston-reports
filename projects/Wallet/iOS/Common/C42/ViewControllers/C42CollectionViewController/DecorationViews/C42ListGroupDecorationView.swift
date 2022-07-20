//
//  C42ListGroupDecorationView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import JustonUI

class C42ListGroupDecorationView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = 16
        
        backgroundColor = .jus_backgroundSecondary
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
