//
//  Created by Anton Spivak.
//  

import UIKit

extension NSAttributedString {
    
    public enum Kern {
        
        case `default`
        case four
    }
    
    public static func string(
        _ string: String?,
        with textStyle: UIFont.TextStyle,
        kern: Kern = .default,
        lineHeight: CGFloat? = nil
    ) -> NSAttributedString {
        guard let string = string
        else {
            return NSAttributedString(string: "")
        }

        let range = NSRange(location: 0, length: string.count)
        let result = NSMutableAttributedString(string: string)
        result.addAttribute(.font, value: UIFont.font(for: textStyle), range: range)
        
        switch kern {
        case .default:
            break
        case .four:
            result.addAttribute(.kern, value: 4, range: range)
        }
        
        if let lineHeight = lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            result.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        guard let copy = result.copy() as? NSAttributedString
        else {
            return NSAttributedString(string: "")
        }
        
        return copy
    }
}
