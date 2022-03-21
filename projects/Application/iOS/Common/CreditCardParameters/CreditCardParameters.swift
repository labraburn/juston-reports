//
//  CreditCardParameters.swift
//  iOS
//
//  Created by Anton Spivak on 13.03.2022.
//

import UIKit
import BilftUI

/// https://en.wikipedia.org/wiki/ISO/IEC_7810
struct CreditCardParameters {
    
    struct CreditCard {
        
        let centeredCreditCardFrame: CGRect
        let topUpCreditCardFrame: CGRect
        let cornerRadius: CGFloat
    }
    
    let rect: CGRect
    let safeAreaInsets: UIEdgeInsets
    let additionalInsets: UIEdgeInsets
    
    func calculate() -> CreditCard {
        let maximumWidth = rect.width - safeAreaInsets.left - safeAreaInsets.right - additionalInsets.left - additionalInsets.right
        let maximumHeight = rect.height - safeAreaInsets.top - safeAreaInsets.bottom - additionalInsets.top - additionalInsets.bottom
        
        let ISOHeight = maximumWidth * 1.585772
        let targetHeight = min(maximumHeight, ISOHeight)
        let cornerRadius = targetHeight * 0.0399
        
        return CreditCard(
            centeredCreditCardFrame: CGRect(
                x: safeAreaInsets.left + additionalInsets.left,
                y: safeAreaInsets.top + additionalInsets.top + (maximumHeight - targetHeight) / 2,
                width: maximumWidth,
                height: targetHeight
            ),
            topUpCreditCardFrame: CGRect(
                x: safeAreaInsets.left + additionalInsets.left,
                y: safeAreaInsets.top + additionalInsets.top,
                width: maximumWidth,
                height: targetHeight
            ),
            cornerRadius: cornerRadius
        )
    }
}
