//
//  SafariViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import SafariServices

class SafariViewController: UIViewController {
    
    override var modalPresentationStyle: UIModalPresentationStyle { get { .pageSheet } set { let _ = newValue } }
    override var isModalInPresentation: Bool {  get { false } set { let _ = newValue }  }
    
    private let viewController: SFSafariViewController
    
    init(url: URL, configuation: SFSafariViewController.Configuration = .init()) {
        viewController = SFSafariViewController(url: url, configuration: configuation)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewController.view.frame = view.bounds
    }
}
