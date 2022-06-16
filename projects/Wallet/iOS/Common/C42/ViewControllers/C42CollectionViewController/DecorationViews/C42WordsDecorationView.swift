//
//  C42WordsDecorationView.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class C42WordsDecorationView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = 16
        
        backgroundColor = .hui_backgroundSecondary
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
