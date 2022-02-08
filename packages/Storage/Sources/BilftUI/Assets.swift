//
//  Created by Anton Spivak.
//

import UIKit

public extension UIColor {
    
    static let bui_backgroundPrimary: UIColor = .named("BackgroundPrimary")
    static let bui_backgroundPrimaryInverted: UIColor = .named("BackgroundPrimaryInverted")
    
    static let bui_textPrimary: UIColor = .named("TextPrimary")
    static let bui_textPrimaryInverted: UIColor = .named("TextPrimaryInverted")
    
    private static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: .module, compatibleWith: nil)
        else {
            fatalError("Can't locale color named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}
