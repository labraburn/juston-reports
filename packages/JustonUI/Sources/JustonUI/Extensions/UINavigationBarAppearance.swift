//
//  Created by Anton Spivak.
//

import UIKit

public extension UINavigationBarAppearance {
    
    private static var jus_titleTextAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.font(for: .title2),
        .foregroundColor : UIColor.jus_textPrimary
    ]
    
    static var jus_standardAppearance: UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.titleTextAttributes = Self.jus_titleTextAttributes
        appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        return appearance
    }
    
    static var jus_scrollEdgeAppearance: UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = Self.jus_titleTextAttributes
        appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        return appearance
    }
}
