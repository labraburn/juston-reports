//
//  SteppableNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonUI
import SystemUI

class SteppableNavigationController: NavigationController {
    
    init(rootViewModel: SteppableViewModel) {
        let viewController = SteppableViewController(model: rootViewModel)
        super.init(rootViewController: viewController)
        modalPresentationStyle = .pageSheet
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
