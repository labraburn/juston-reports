//
//  PreferredContentSizeHeightViewController.swift
//  iOS
//
//  Created by Anton Spivak on 19.07.2022.
//

import UIKit

protocol PreferredContentSizeHeightViewController: UIViewController {
    
    func preferredContentSizeHeight(
        with containerFrame: CGRect
    ) -> CGFloat
}
