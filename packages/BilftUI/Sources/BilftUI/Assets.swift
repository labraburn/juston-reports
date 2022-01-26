//
//  Created by Anton Spivak.
//

import UIKit

public extension UIColor {
    
    static let oui_backgroundPrimary: UIColor = .named("BackgroundPrimary")
    static let oui_backgroundPrimaryInverted: UIColor = .named("BackgroundPrimaryInverted")
    
    static let oui_textPrimary: UIColor = .named("TextPrimary")
    static let oui_textPrimaryInverted: UIColor = .named("TextPrimaryInverted")
    
    private static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: .module, compatibleWith: nil)
        else {
            fatalError("Can't locale color named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}
