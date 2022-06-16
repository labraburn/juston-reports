//
//  RelativeDateFormatter.swift
//  iOS
//
//  Created by Anton Spivak on 08.02.2022.
//

import Foundation

extension RelativeDateTimeFormatter {
    
    static let shared: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}
