//
//  Created by Anton Spivak.
//

import UIKit

public extension UIColor {
    
    static let hui_accent: UIColor = .named("ApplicationAccent")
    static let hui_tint: UIColor = .named("ApplicationTint")
    
    static let hui_backgroundPrimary: UIColor = .named("BackgroundPrimary")
    static let hui_backgroundSecondary: UIColor = .named("BackgroundSecondary")
    
    static let hui_textPrimary: UIColor = .named("TextPrimary")
    static let hui_textSecondary: UIColor = .named("TextSecondary")
    static let hui_textTeritary: UIColor = .named("TextTeritary")
    
    private static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: .module, compatibleWith: nil)
        else {
            fatalError("Can't locale color named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}

public extension UIImage {
    
    static let hui_send24: UIImage = .named("Send24")
    static let hui_receive24: UIImage = .named("Receive24")
    static let hui_more24: UIImage = .named("More24")
    static let hui_addCircle24: UIImage = .named("AddCircle24")
    
    static let hui_placeholder512: UIImage = .named("Placeholder512")
    
    private static func named(_ name: String) -> UIImage {
        guard let color = UIImage(named: name, in: .module, with: nil)
        else {
            fatalError("Can't locale image named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}
