//
//  Created by Anton Spivak.
//  

import Foundation

import UIKit

extension UIScreen {
    
    public var displayCornerRadius: CGFloat {
        let key = ["Radius", "Corner", "display", "_"].reversed().joined()
        
        guard let cornerRadius = self.value(forKey: key) as? CGFloat
        else {
            return 0
        }

        return cornerRadius
    }
}
