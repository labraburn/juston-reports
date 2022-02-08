//
//  HeaderViewController.swift
//  HeaderPageViewController
//
//  Created by Anton Spivak on 10.12.2021.
//

import UIKit

class HeaderViewController: UIViewController {
    private var buttonBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .cyan

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Animate", for: .normal)
        button.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)

        view.addSubview(button)

        buttonBottomConstraint = button.topAnchor.constraint(equalTo: view.topAnchor, constant: 150)
        buttonBottomConstraint?.isActive = true

        view.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 150).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

        // Requirement of UnicornUI.HeaderPageViewController
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Actions

    @objc
    private func buttonDidClick(_ sender: UIButton) {
        buttonBottomConstraint?.constant = 220
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}
