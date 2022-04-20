//
//  UserBookmark.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit

struct UserBookmark {
    
    let name: String
    let url: URL
    let image: UIImage?
}

extension UserBookmark: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
