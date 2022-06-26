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
        didChangeValue textField: UITextField
    )
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didEndEditing textField: UITextField
    )
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didClickActionsButton button: UIButton
    )
}

final class AccountStackBrowserNavigationView: UIView {
    
    private let searchField = AccountStackBrowserSearchField().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    var title: String? {
        get { searchField.title }
        set { searchField.title = newValue }
    }
    
    weak var delegate: AccountStackBrowserNavigationViewDelegate?
    
    init() {
        super.init(frame: .zero)

        searchField.actionsButton.addTarget(
            self,
            action: #selector(actionsButtonDidClick(_:)),
            for: .touchUpInside
        )
        
        searchField.textField.delegate = self
        searchField.textField.addTarget(
            self,
            action: #selector(handleTextFieldDidChange(_:)),
            for: .valueChanged
        )
        
        addSubview(searchField)
        
        NSLayoutConstraint.activate({
            heightAnchor.pin(to: 64)
            
            searchField.pin(vertically: self, top: 8, bottom: 8)
            searchField.pin(horizontally: self, left: 12, right: 12)
        })
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLoading(
        _ loading: Bool
    ) {
        searchField.setLoading(loading)
    }
    
    func setKeyboardTouchSafeAreaInsets(
        _ insets: UIEdgeInsets
    ) {
        sui_touchAreaInsets = insets
        searchField.setKeyboardTouchSafeAreaInsets(sui_touchAreaInsets)
    }
    
    func setActiveURL(
        _ url: URL?
    ) {
        searchField.actionsButton.isEnabled = url != nil
        
        guard let url = url
        else {
            return
        }
        
        searchField.textField.text = url.absoluteString
    }
    
    // MARK: Actions
    
    @objc
    private func handleTextFieldDidChange(_ sender: UITextField) {
        delegate?.navigationView(self, didChangeValue: sender)
    }
    
    @objc
    private func actionsButtonDidClick(_ sender: UIButton) {
        delegate?.navigationView(self, didClickActionsButton: sender)
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
