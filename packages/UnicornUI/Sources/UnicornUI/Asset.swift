//
//  Created by Anton Spivak
//

import UIKit

/*
 Extensions of lazy initialized images from module bundle
 */
internal extension Asset.Image {
    static let search24: UIImage = named("Search24")
    static let cancel16: UIImage = named("Cancel16")
}

/*
 Extensions of lazy initialized colors from module bundle
 */
internal extension Asset.Color {
    static let tint: UIColor = named("Tint")

    static let textPrimary: UIColor = named("TextPrimary")
    static let textSecondary: UIColor = named("TextSecondary")

    static let inputFieldBorder: UIColor = named("InputFieldBorder")
    static let inputFieldBackground: UIColor = named("InputFieldBackground")

    static let inputText: UIColor = named("InputText")
    static let inputTextPlaceholder: UIColor = named("InputTextPlaceholder")
}

/*
 Extensions of static sizes
 */
internal extension Asset.Size {
    /// 16 pt
    static let paddingLarge: CGFloat = 16
    /// 12 pt
    static let paddingNormal: CGFloat = 12
    /// 8 pt
    static let padding: CGFloat = 8
    /// 6 pt
    static let paddingSmall: CGFloat = 8

    /// 16 pt
    static let cornerRadius: CGFloat = 16
    /// 12 pt
    static let cornerRadiusMedium: CGFloat = 12
    /// 8 pt
    static let cornerRadiusSmall: CGFloat = 8
    /// 6 pt
    static let cornerRadiusSmallX: CGFloat = 6
    /// 4 pt
    static let cornerRadiusSmallXX: CGFloat = 4
}

internal enum Asset {
    internal enum Size {}

    internal enum Image {
        fileprivate static func named(
            _ name: String,
            compatibleWith traitCollection: UITraitCollection? = nil
        ) -> UIImage {
            guard let image = UIImage(named: name, in: .module, compatibleWith: traitCollection)
            else {
                fatalError("Could not find image named \(name) in bundle: \(Bundle.module)")
            }

            return image
        }
    }

    internal enum Color {
        fileprivate static func named(
            _ name: String,
            compatibleWith traitCollection: UITraitCollection? = nil
        ) -> UIColor {
            guard let color = UIColor(named: name, in: .module, compatibleWith: traitCollection)
            else {
                fatalError("Could not find color named \(name) in bundle: \(Bundle.module)")
            }

            return color
        }
    }
}
