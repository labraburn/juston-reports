//
//  Created by Anton Spivak.
//  

import UIKit

extension NSAttributedString {
    
    public enum Kern {
        
        case `default`
        case four
        case custom(value: CGFloat)
    }
    
    public convenience init(
        _ string: String?,
        with textStyle: UIFont.TextStyle,
        kern: Kern = .default,
        foregroundColor: UIColor = .jus_textPrimary,
        lineHeight: CGFloat? = nil
    ) {
        guard let string = string
        else {
            self.init(string: "")
            return
        }
        
        var attributes: [NSMutableAttributedString.Key : Any] = [:]
        attributes[.font] = UIFont.font(for: textStyle)
        attributes[.foregroundColor] = foregroundColor
        
        switch kern {
        case .default:
            break
        case .four:
            attributes[.kern] = 4
        case let .custom(value):
            attributes[.kern] = value
        }
        
        if let lineHeight = lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        self.init(string: string, attributes: attributes)
    }
    
    public static func string(
        _ string: String?,
        with textStyle: UIFont.TextStyle,
        kern: Kern = .default,
        foregroundColor: UIColor = .jus_textPrimary,
        lineHeight: CGFloat? = nil
    ) -> NSAttributedString {
        NSAttributedString(
            string,
            with: textStyle,
            kern: kern,
            foregroundColor: foregroundColor,
            lineHeight: lineHeight
        )
    }
}
