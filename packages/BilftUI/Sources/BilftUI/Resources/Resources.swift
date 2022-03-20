//
//  Created by Anton Spivak.
//

import UIKit

public extension UIColor {
    
    static let bui_backgroundPrimary: UIColor = .named("BackgroundPrimary")
    static let bui_backgroundSecondary: UIColor = .named("BackgroundSecondary")
    
    static let bui_textPrimary: UIColor = .named("TextPrimary")
    static let bui_textTeritary: UIColor = .named("TextTeritary")
    
    private static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: .module, compatibleWith: nil)
        else {
            fatalError("Can't locale color named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}

public extension UIImage {
    
    static let bui_send24: UIImage = .named("Send24")
    static let bui_receive24: UIImage = .named("Receive24")
    static let bui_more24: UIImage = .named("More24")
    
    private static func named(_ name: String) -> UIImage {
        guard let color = UIImage(named: name, in: .module, with: nil)
        else {
            fatalError("Can't locale image named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}
