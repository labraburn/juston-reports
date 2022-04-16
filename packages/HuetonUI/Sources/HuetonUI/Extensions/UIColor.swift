//
//  Created by Anton Spivak.
//

import UIKit

extension UIColor {
    
    public convenience init(rgb: Int) {
        self.init(
            red: (rgb & 0xFF0000) >> 16,
            green: (rgb & 0x00FF00) >> 8,
            blue: (rgb & 0x0000FF),
            alpha: 0xFF
        )
    }
    
    public convenience init(rgba: Int) {
        self.init(
            red: (rgba & 0xFF000000) >> 24,
            green: (rgba & 0x00FF0000) >> 16,
            blue: (rgba & 0x0000FF00) >> 8,
            alpha: (rgba & 0x000000FF)
        )
    }
    
    public convenience init(red: Int, green: Int, blue: Int, alpha: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 255, "Invalid alpha component")
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
    
    public func rgba() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
