//
//  LaunchViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    
    func launchViewController(_ viewController: LaunchViewController, didFinishAnimation finished: Bool)
}

class LaunchViewController: UIViewController {
    
    private var launchView: LaunchView { view as! LaunchView }
    weak var delegate: LaunchViewControllerDelegate? = nil
    
    override func loadView() {
        let view = LaunchView()
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        launchView.animate(completion: { finished in
            self.laucnhDidComplete(finished)
        })
    }
    
    // MARK: Private
    
    private func laucnhDidComplete(_ finished: Bool) {
        delegate?.launchViewController(self, didFinishAnimation: finished)
    }
}
