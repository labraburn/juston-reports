//
//  SCLS3000ListGroupDecorationView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

class SCLS3000ListGroupDecorationView: UICollectionReusableView {
    
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
