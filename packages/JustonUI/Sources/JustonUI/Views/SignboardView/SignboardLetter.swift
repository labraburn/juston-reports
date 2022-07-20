//
//  Created by Anton Spivak.
//

import UIKit

public final class SignboardLetter {
    
    public let character: Character
    public let color: UIColor
    
    internal var observer: ((_ letter: SignboardLetter) -> ())?
    
    internal var tintColor: UIColor {
        switch tumbler {
        case .on:
            return color
        case .off:
            return UIColor(rgb: 0x3C3C3C)
        }
    }
    
    public var tumbler: SignboardTumbler {
        didSet {
            guard tumbler != oldValue
            else {
                return
            }
            
            observer?(self)
        }
    }
    
    public init(
        character: Character,
        color: UIColor,
        tumbler: SignboardTumbler
    ) {
        self.character = character
        self.color = color
        self.tumbler = tumbler
    }
}
