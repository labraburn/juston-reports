//
//  AccountStackView.swift
//  iOS
//
//  Created by Anton Spivak on 23.06.2022.
//

import UIKit
import HuetonUI

final class AccountStackView: UIView {
    
    static let compactCardStackViewHeight = CGFloat(96)
    static let compactTopHeight = CGFloat(112)
    static let compactBottomHeight = CGFloat(112)
    
    private var topLineView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(rgb: 0x353535)
    })
    
    private var bottomLineView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(rgb: 0x353535)
    })
    
    private let cardStackContainerView = ContainerView<CardStackView>().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let navigationStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .equalCentering
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -24)
        $0.backgroundColor = .hui_backgroundPrimary
    })
    
    let browserNavigationView = AccountStackBrowserNavigationView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundPrimary
    })

    let logotypeView = AccountStackLogotypeView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let scanQRButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -12)
        $0.setImage(.hui_scan20, for: .normal)
        $0.tintColor = .hui_textPrimary
    })
    
    let addAccountButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -12)
        $0.setImage(.hui_addCircle20, for: .normal)
        $0.tintColor = .hui_textPrimary
    })
    
    private var compactTopConstraints: [NSLayoutConstraint] = []
    private var largeConstraints: [NSLayoutConstraint] = []
    private var compactBottomConstraints: [NSLayoutConstraint] = []
    
    var triplePresentation: TriplePresentation = .middle {
        didSet {
            guard triplePresentation != oldValue
            else {
                return
            }
            
            NSLayoutConstraint.deactivate(compactTopConstraints)
            NSLayoutConstraint.deactivate(largeConstraints)
            NSLayoutConstraint.deactivate(compactBottomConstraints)
            
            switch triplePresentation {
            case .top:
                cardStackView?.presentation = .compact
                NSLayoutConstraint.activate(compactTopConstraints)
            case .middle:
                cardStackView?.presentation = .large
                NSLayoutConstraint.activate(largeConstraints)
            case .bottom:
                cardStackView?.presentation = .compact
                NSLayoutConstraint.activate(compactBottomConstraints)
            }
            
            setNeedsLayout()
        }
    }
    
    var cardStackView: CardStackView? {
        get { cardStackContainerView.enclosingView }
        set { cardStackContainerView.enclosingView = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        addSubview(topLineView)
        addSubview(bottomLineView)
        
        navigationStackView.addArrangedSubview(scanQRButton)
        navigationStackView.addArrangedSubview({
            let touchAreaInsets = UIEdgeInsets(top: -24, left: 0, right: 0, bottom: -24)
            let wrapperView = UIView()
            wrapperView.addSubview(logotypeView)
            wrapperView.heightAnchor.pin(to: HuetonView.applicationHeight).isActive = true
            logotypeView.pinned(edges: wrapperView)
            
            wrapperView.sui_touchAreaInsets = touchAreaInsets
            logotypeView.sui_touchAreaInsets = touchAreaInsets
            
            return wrapperView
        }())
        navigationStackView.addArrangedSubview(addAccountButton)
        
        addSubview(browserNavigationView)
        addSubview(navigationStackView)
        addSubview(cardStackContainerView)
        
        compactTopConstraints = Array({
            browserNavigationView.topAnchor.pin(to: topAnchor, constant: 8)
            browserNavigationView.pin(horizontally: self, left: 0, right: 0)
            
            navigationStackView.centerYAnchor.pin(to: centerYAnchor)
            navigationStackView.pin(horizontally: self, left: 24, right: 24)
            navigationStackView.heightAnchor.pin(to: 52)
            
            cardStackContainerView.topAnchor.pin(to: browserNavigationView.bottomAnchor, constant: 12)
            cardStackContainerView.heightAnchor.pin(to: AccountStackView.compactCardStackViewHeight)
            cardStackContainerView.pin(horizontally: self, left: 12, right: 12)
        })
        
        largeConstraints = Array({
            browserNavigationView.centerYAnchor.pin(to: centerYAnchor)
            browserNavigationView.pin(horizontally: self, left: 0, right: 0)
            
            navigationStackView.topAnchor.pin(to: safeAreaLayoutGuide.topAnchor, constant: 16)
            navigationStackView.pin(horizontally: self, left: 24, right: 24)
            navigationStackView.heightAnchor.pin(to: 52)
            
            cardStackContainerView.topAnchor.pin(to: navigationStackView.bottomAnchor, constant: 0)
            cardStackContainerView.pin(horizontally: self, left: 12, right: 12)
            
            safeAreaLayoutGuide.bottomAnchor.pin(to: cardStackContainerView.bottomAnchor, constant: 42)
        })
        
        compactBottomConstraints = Array({
            browserNavigationView.centerYAnchor.pin(to: centerYAnchor)
            browserNavigationView.pin(horizontally: self, left: 0, right: 0)
            
            navigationStackView.centerYAnchor.pin(to: centerYAnchor)
            navigationStackView.pin(horizontally: self, left: 24, right: 24)
            navigationStackView.heightAnchor.pin(to: 52)
            
            cardStackContainerView.heightAnchor.pin(to: AccountStackView.compactCardStackViewHeight)
            cardStackContainerView.pin(horizontally: self, left: 12, right: 12)
            bottomAnchor.pin(to: cardStackContainerView.bottomAnchor, constant: 12)
        })
        
        NSLayoutConstraint.activate(largeConstraints)
        NSLayoutConstraint.activate({
            topLineView.topAnchor.pin(to: topAnchor)
            topLineView.pin(horizontally: self)
            topLineView.heightAnchor.pin(to: 1)
            
            bottomLineView.pin(horizontally: self)
            bottomLineView.heightAnchor.pin(to: 1)
            bottomAnchor.pin(to: bottomLineView.bottomAnchor)
        })
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrameNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification(_:)),
            name: UIWindow.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let s = super.point(inside: point, with: event)
        return s
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardStackView?.cornerRadius = 16
        switch triplePresentation {
        case .top:
            topLineView.alpha = 1
            bottomLineView.alpha = 0
            
            navigationStackView.alpha = 0
            browserNavigationView.alpha = 1
        case .middle:
            topLineView.alpha = 0
            bottomLineView.alpha = 0
            
            navigationStackView.alpha = 1
            browserNavigationView.alpha = 0
        case .bottom:
            topLineView.alpha = 0
            bottomLineView.alpha = 1
            
            navigationStackView.alpha = 0
            browserNavigationView.alpha = 0
        }
    }
    
    func perfromApperingAnimation() {
        logotypeView.huetonView.perfromLoadingAnimationAndStartInfinity()
    }
    
    // MARK: Actions
    
    // Hack for textField
    @objc
    private func keyboardWillShowNotification(_ notification: Notification) {
        keyboardDidChangeFrameNotification(notification)
    }
    
    // Hack for textField
    @objc
    private func keyboardDidChangeFrameNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let frame = frameValue.cgRectValue
        let maximumTouchInset = UIEdgeInsets(top: -frame.height)
        let minimumTouchInset = UIEdgeInsets(top: -frame.height + Self.compactCardStackViewHeight)
        
        sui_touchAreaInsets = minimumTouchInset
        superview?.sui_touchAreaInsets = minimumTouchInset
        
        browserNavigationView.setKeyboardTouchSafeAreaInsets(maximumTouchInset)
    }
    
    // Hack for textField
    @objc
    private func keyboardWillHideNotification(_ notification: Notification) {
        sui_touchAreaInsets = UIEdgeInsets(top: 0)
        superview?.sui_touchAreaInsets = sui_touchAreaInsets
        browserNavigationView.setKeyboardTouchSafeAreaInsets(sui_touchAreaInsets)
    }
}

extension HuetonView {
    
    static var applicationHeight = CGFloat(20)
}
