//
//  AccountStackBrowserSearchField.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import HuetonUI

final class AccountStackBrowserSearchField: UIControl {
    
    private let borderView = GradientBorderedView(colors: [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)]).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.cornerRadius = 16
    })
    
    private let substrateView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .hui_backgroundSecondary
        $0.layer.cornerRadius = 16
        $0.layer.cornerCurve = .continuous
    })
    
    private var substrateBottomConstraint: KeyboardLayoutConstraint?
    
    let textField = UITextField().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Search or enter web3site"
        $0.isUserInteractionEnabled = false
        $0.textContentType = .URL
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .go
        $0.smartQuotesType = .no
        $0.smartDashesType = .no
        $0.clearButtonMode = .whileEditing
    })
    
    init() {
        super.init(frame: .zero)
        
        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .soft)
        
        addSubview(substrateView)
        addSubview(borderView)
        addSubview(textField)
        
        let substrateBottomConstraint = KeyboardLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .greaterThanOrEqual,
            toItem: substrateView,
            attribute: .bottom,
            multiplier: 1,
            constant: 4
        )
        
        NSLayoutConstraint.activate({
            substrateView.heightAnchor.pin(to: 54)
            substrateView.pin(horizontally: self, left: 12, right: 12)
            substrateBottomConstraint
            
            textField.pin(vertically: substrateView, top: 1, bottom: 3)
            textField.pin(horizontally: substrateView, left: 10, right: 10)
            
            borderView.pin(edges: substrateView)
        })
        
        addTarget(
            self,
            action: #selector(handleDidClick(_:)),
            for: .touchUpInside
        )
        
        self.substrateBottomConstraint = substrateBottomConstraint
        self.setFocused(false, animated: false)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // Heheheheheheheheheheheheheh
        let anchorView = superview?.subviews.last ?? self
        substrateBottomConstraint?.bottomAnchor = .view(view: .init(anchorView))
    }
    
    func setFocused(_ flag: Bool, animated: Bool = true) {
        let changes = {
            self.borderView.gradientColors = flag ? [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)] : [.hui_textSecondary, .hui_textSecondary]
            self.borderView.gradientAngle = flag ? 12 : 68
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.21,
                delay: 0,
                options: [.beginFromCurrentState],
                animations: changes,
                completion: nil
            )
        } else {
            changes()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func handleDidClick(_ sender: UIControl) {
        guard !textField.isFirstResponder
        else {
            return
        }
        
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
    }
}
