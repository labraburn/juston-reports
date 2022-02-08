//
//  UnicornUI.swift
//
//
//  Created by Anton Spivak on 28.01.2022.
//

import UIKit

func UIKitLocalizedString(for key: String) -> String {
    Bundle(identifier: "com.apple.UIKit")?.localizedString(
        forKey: key,
        value: "",
        table: nil
    ) ?? key
}
