//
//  ApplicationWindowViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import JustonUI

class ApplicationWindowViewController: ContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .jus_backgroundPrimary
    }
}

extension UIView {
    
    var applicationWindow: ApplicationWindow? {
        window as? ApplicationWindow
    }
}
