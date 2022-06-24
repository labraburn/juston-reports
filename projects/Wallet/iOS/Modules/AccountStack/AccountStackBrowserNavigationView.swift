//
//  AccountStackBrowserNavigationView.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit

protocol AccountStackBrowserNavigationViewDelegate: AnyObject {
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didStartEditing textField: UITextField
    )
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didEndEditing textField: UITextField
    )
}

final class AccountStackBrowserNavigationView: UIStackView {
    
    private let actionsStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    })
    
    private let searchField = AccountStackBrowserSearchField().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let backButton = AccountStackBrowserNavigationView.actionButtonWithImageNamed("chevron.backward")
    let forwardButton = AccountStackBrowserNavigationView.actionButtonWithImageNamed("chevron.forward")
    let favouriteButton = AccountStackBrowserNavigationView.actionButtonWithImageNamed("star")
    let shareButton = AccountStackBrowserNavigationView.actionButtonWithImageNamed("square.and.arrow.up")
    
    var textField: UITextField {
        searchField.textField
    }
    
    weak var delegate: AccountStackBrowserNavigationViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        axis = .vertical
        alignment = .fill
        distribution = .fill
        
        textField.delegate = self
        
        searchField.heightAnchor.pin(to: 62).isActive = true
        actionsStackView.heightAnchor.pin(to: 44).isActive = true
        
        actionsStackView.addArrangedSubview(backButton)
        actionsStackView.addArrangedSubview(forwardButton)
        actionsStackView.addArrangedSubview(favouriteButton)
        actionsStackView.addArrangedSubview(shareButton)
        
        addArrangedSubview(searchField)
        addArrangedSubview(actionsStackView)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func actionButtonWithImageNamed(
        _ systemName: String
    ) -> UIButton {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: 22,
            weight: .medium
        )
        
        return UIButton().with({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(
                UIImage(
                    systemName: systemName,
                    withConfiguration: configuration
                ),
                for: .normal
            )
        })
    }
}

extension AccountStackBrowserNavigationView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchField.setFocused(true)
        textField.isUserInteractionEnabled = true
        delegate?.navigationView(self, didStartEditing: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchField.setFocused(false)
        textField.isUserInteractionEnabled = false
        delegate?.navigationView(self, didEndEditing: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}
