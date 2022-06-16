//
//  AlertViewControllerImage.swift
//  iOS
//
//  Created by Anton Spivak on 02.04.2022.
//

import Foundation
import UIKit

struct AlertViewControllerImage {
    
    let image: UIImage?
    let tintColor: UIColor?
    
    private init(
        image: UIImage?,
        tintColor: UIColor?
    ) {
        self.image = image
        self.tintColor = tintColor
    }
    
    static func image(_ image: UIImage?, tintColor: UIColor? = nil) -> AlertViewControllerImage {
        AlertViewControllerImage(image: image, tintColor: tintColor)
    }
}
