//
//  AccountStackBrowserSearchField.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import HuetonUI
import SystemUI

final class AccountStackBrowserSearchField: UIControl {
    
    private class TitleLabel: UILabel {
        
        var insets: UIEdgeInsets = .zero {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func drawText(in rect: CGRect) {
            super.drawText(
                in: rect.inset(
                    by: insets
                )
            )
        }
    }
    
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
    
    private let titleLabel = TitleLabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .font(for: .subheadline)
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.layer.cornerRadius = 16
        $0.layer.cornerCurve = .continuous
        $0.textColor = .hui_textPrimary
    })
    
    private let gradientImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = .hui_searchFieldGradient
    })
    
    private let loadingView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 16
        $0.layer.cornerCurve = .continuous
    })
    
    private var substrateBottomConstraint: KeyboardLayoutConstraint?
    
    let textField = UITextField().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Search or enter web3site"
        $0.textColor = .hui_textPrimary
        $0.isUserInteractionEnabled = false
        $0.textContentType = .URL
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .go
        $0.smartQuotesType = .no
        $0.smartDashesType = .no
        $0.clearButtonMode = .whileEditing
    })
    
    let actionsButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .hui_letter_purple
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .soft)
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -64)
        $0.setImage(
            UIImage(
                systemName: "command",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 22,
                    weight: .medium
                )
            ),
            for: .normal
        )
    })
    
    var title: String? {
        didSet {
            guard !textField.isFirstResponder
            else {
                return
            }
            
            titleLabel.text = title
            showTitleElseTextFieldAnimated(
                animated: true
            )
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        sui_touchAreaInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -64)
        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .soft)
        
        addSubview(substrateView)
        addSubview(textField)
        addSubview(titleLabel)
        addSubview(gradientImageView)
        addSubview(borderView)
        addSubview(actionsButton)
        addSubview(loadingView)
        
        let substrateBottomConstraint = KeyboardLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .greaterThanOrEqual,
            toItem: substrateView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        substrateBottomConstraint.keyboardOffset = 0
        substrateBottomConstraint.bottomAnchor = .view(view: .init(self))
        substrateBottomConstraint.responderChecker = .view(view: .init(textField))
        
        let actionsButtonWidth = CGFloat(44)
        titleLabel.insets = UIEdgeInsets(right: -(actionsButtonWidth - 8))
        
        NSLayoutConstraint.activate({
            substrateView.heightAnchor.pin(to: heightAnchor)
            substrateView.pin(horizontally: self)
            substrateBottomConstraint
            
            actionsButton.pin(vertically: substrateView)
            actionsButton.widthAnchor.pin(to: actionsButtonWidth)
            rightAnchor.pin(to: actionsButton.rightAnchor, constant: 6)
            
            textField.pin(vertically: substrateView, top: 1, bottom: 3)
            textField.leftAnchor.pin(to: leftAnchor, constant: 10)
            actionsButton.leftAnchor.pin(to: textField.rightAnchor, constant: 2)
            
            titleLabel.pin(edges: textField)
            gradientImageView.pin(edges: textField)
            
            borderView.pin(edges: substrateView)
            loadingView.pin(edges: substrateView)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        substrateBottomConstraint?.keyboardOffset = bounds.height + 16
    }
    
    func setLoading(
        _ loading: Bool
    ) {
        if loading {
            loadingView.startLoadingAnimation(delay: 0, fade: false)
        } else {
            loadingView.stopLoadingAnimation()
        }
        
        loadingView.isUserInteractionEnabled = false
    }
    
    func setFocused(_ flag: Bool, animated: Bool = true) {
        let changes = {
            self.borderView.gradientColors = flag ? [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)] : [.hui_textSecondary, .hui_textSecondary]
            self.borderView.gradientAngle = flag ? 12 : 68
            
            if flag {
                self.showTextFieldAnimated(
                    animated: false
                )
            } else {
                self.showTitleElseTextFieldAnimated(
                    animated: false
                )
            }
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
    
    func setKeyboardTouchSafeAreaInsets(
        _ insets: UIEdgeInsets
    ) {
        switch insets {
        case .zero:
            sui_touchAreaInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -64)
        default:
            sui_touchAreaInsets = insets
        }
    }
    
    private func showTextFieldAnimated(
        animated: Bool
    ) {
        let changes = {
            self.titleLabel.alpha = 0
            self.textField.alpha = 1
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
    
    private func showTitleElseTextFieldAnimated(
        animated: Bool
    ) {
        let changes = {
            self.titleLabel.alpha = self.title == nil ? 0 : 1
            self.textField.alpha = self.title == nil ? 1 : 0
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
