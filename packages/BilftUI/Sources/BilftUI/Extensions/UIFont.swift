//
//  Created by Anton Spivak.
//  

import UIKit


extension UIFont {
    
    private struct FontDescription {
        
        let size: CGFloat
        let weight: UIFont.Weight

        init(size: CGFloat, weight: UIFont.Weight = .regular) {
            self.size = size
            self.weight = weight
        }
    }
    
    private static let fonts: [UIFont.TextStyle: FontDescription] = [
        .largeTitle: .init(size: 34, weight: .heavy),
        .title1: .init(size: 28, weight: .bold),
        .title2: .init(size: 22, weight: .bold),
        .title3: .init(size: 20, weight: .bold),
        .headline: .init(size: 17.0, weight: .semibold),
        .body: .init(size: 17),
        .callout: .init(size: 16),
        .subheadline: .init(size: 15, weight: .regular),
        .footnote: .init(size: 13),
        .caption1: .init(size: 12),
        .caption2: .init(size: 11),
    ]
    
    public static func font(
        `for` textStyle: UIFont.TextStyle
    ) -> UIFont {
        guard let description = fonts[textStyle]
        else {
            #if DEBUG
            fatalError("No font for style: \(textStyle) did found")
            #else
            return .preferredFont(forTextStyle: textStyle)
            #endif
        }

        return .monospacedSystemFont(
            ofSize: description.size,
            weight: description.weight
        )
    }
}
