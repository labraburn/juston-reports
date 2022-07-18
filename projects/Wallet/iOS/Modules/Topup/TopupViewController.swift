//
//  TopupViewController.swift
//  iOS
//
//  Created by Anton Spivak on 18.07.2022.
//

import UIKit
import HuetonUI

protocol TopupViewControllerDelegate: AnyObject {
    
    func topupViewController(
        _ viewController: TopupViewControllerDelegate,
        didFinishWithError error: Error?
    )
}

class TopupViewController: SafariViewController {
    
    weak var delegate: TopupViewControllerDelegate? = nil
    
    init() {
        guard let url = URL(string: "https://iframe.venera.exchange/?theme=dark")
        else {
            fatalError("[TopupViewController]: Can't create URL.")
        }
        
        super.init(url: url, navigationItems: [.url], bottomItems: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
