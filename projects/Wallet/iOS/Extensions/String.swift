//
//  String.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import Foundation

extension String {
    
    var asLocalizedKey: String {
        Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}
