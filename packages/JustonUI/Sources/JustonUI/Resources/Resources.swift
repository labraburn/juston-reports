//
//  Created by Anton Spivak.
//

import UIKit

public extension UIColor {
    
    static let jus_accent: UIColor = .named("ApplicationAccent")
    static let jus_tint: UIColor = .named("ApplicationTint")
    
    static let jus_backgroundPrimary: UIColor = .named("BackgroundPrimary")
    static let jus_backgroundSecondary: UIColor = .named("BackgroundSecondary")
    
    static let jus_textPrimary: UIColor = .named("TextPrimary")
    static let jus_textSecondary: UIColor = .named("TextSecondary")
    static let jus_textTeritary: UIColor = .named("TextTeritary")
    
    static let jus_tabBarDeselected: UIColor = .named("TabBarDeselected")
    
    static let jus_letter_red: UIColor = .named("Letter/Red")
    static let jus_letter_yellow: UIColor = .named("Letter/Yellow")
    static let jus_letter_blue: UIColor = .named("Letter/Blue")
    static let jus_letter_green: UIColor = .named("Letter/Green")
    static let jus_letter_violet: UIColor = .named("Letter/Violet")
    static let jus_letter_purple: UIColor = .named("Letter/Purple")
    
    private static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: .module, compatibleWith: nil)
        else {
            fatalError("Can't locale color named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}

public extension UIImage {
    
    static let jus_addCircle20: UIImage = .named("AddCircle20")
    static let jus_scan20: UIImage = .named("Scan20")
    static let jus_gear20: UIImage = .named("Gear20")
    static let jus_sparkles20: UIImage = .named("Sparkles20")
    static let jus_radioButtonSelected20: UIImage = .named("RadioButtonSelected20")
    static let jus_radioButtonDeselected20: UIImage = .named("RadioButtonDeselected20")
    
    static let jus_send24: UIImage = .named("Send24")
    static let jus_receive24: UIImage = .named("Receive24")
    static let jus_more24: UIImage = .named("More24")
    static let jus_info24: UIImage = .named("Info24")
    static let jus_copy24: UIImage = .named("Copy24")
    static let jus_done24: UIImage = .named("Done24")
    
    static let jus_cardButtonCredit55: UIImage = .named("CardButtonCredit55")
    static let jus_cardButtonMore55: UIImage = .named("CardButtonMore55")
    static let jus_cardButtonReceive55: UIImage = .named("CardButtonReceive55")
    static let jus_cardButtonSend55: UIImage = .named("CardButtonSend55")
    
    static let jus_info42: UIImage = .named("Info42")
    static let jus_error42: UIImage = .named("Error42")
    static let jus_warning42: UIImage = .named("Warning42")
    static let jus_development42: UIImage = .named("Development42")
    
    static let jus_sendColor51: UIImage = .named("SendColor51")
    static let jus_receiveColor51: UIImage = .named("ReceiveColor51")
    
    static let jus_placeholderV1512: UIImage = .named("PlaceholderV1512")
    static let jus_placeholderV2512: UIImage = .named("PlaceholderV2512")
    static let jus_placeholderV3512: UIImage = .named("PlaceholderV3512")
    static let jus_placeholderV4512: UIImage = .named("PlaceholderV4512")
    static let jus_placeholderV5512: UIImage = .named("PlaceholderV5512")
    
    static let jus_qrCodeOverlay512: UIImage = .named("QRCodeOverlay512")
    static let jus_veneraExchange128: UIImage = .named("VeneraExchange")
    static let jus_veneraJuston128: UIImage = .named("VeneraJuston")
    
    static let jus_cardGradient0: UIImage = .named("CardGradient0")
    static let jus_cardGradient1: UIImage = .named("CardGradient1")
    static let jus_cardGradient2: UIImage = .named("CardGradient2")
    static let jus_cardGradient3: UIImage = .named("CardGradient3")
    static let jus_cardGradient4: UIImage = .named("CardGradient4")
    static let jus_cardGradient5: UIImage = .named("CardGradient5")
    
    static let jus_appIcon128: UIImage = .named("AppIcon128")
    
    static let jus_tabBarCards44: UIImage = .named("TabBar/Cards44")
    static let jus_tabBarGear44: UIImage = .named("TabBar/Gear44")
    static let jus_tabBarPlanet44: UIImage = .named("TabBar/Planet44")
    
    static let jus_searchFieldGradient: UIImage = .named("SearchFiledGradient")
    
    private static func named(_ name: String) -> UIImage {
        guard let color = UIImage(named: name, in: .module, with: nil)
        else {
            fatalError("Can't locale image named '\(name)' in bundle '\(Bundle.module.bundlePath)'")
        }
        
        return color
    }
}
