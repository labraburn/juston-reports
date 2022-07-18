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
        
        super.init(initial: .html(value: .venera), navigationItems: [.url], bottomItems: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension String {
    
    static let venera =
    """
    <!DOCTYPE html>
    <html>
    <head>
    <title>Top-up balance</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0">
    <style>
    body {
      background-color: #10080E;
      width: 100%;
      height: 100%;
      margin: 0px;
    }
    div {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      margin: 0px;
    }
    iframe {
      border-style: none;
      width: 360px;
      height: 540px;
    }
    </style>
    </head>
    <body>
    <div>
    <iframe class="iframe" src="https://iframe.venera.exchange/?theme=dark" frameborder="0"></iframe>
    </div>
    </body>
    </html>
    """
}
