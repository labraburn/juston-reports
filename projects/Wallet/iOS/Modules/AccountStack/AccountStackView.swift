//
//  AccountStackView.swift
//  iOS
//
//  Created by Anton Spivak on 23.06.2022.
//

import UIKit
import HuetonUI

final class AccountStackView: UIView {
    
    enum LayoutPin: Equatable {
        
        case top
        case bottom
    }
    
    enum LayoutKind: Equatable {
        
        case large
        case compact(height: CGFloat, pin: LayoutPin)
    }
    
    private var topLineView = UIView().with({
        $0.backgroundColor = UIColor(rgb: 0x353535)
    })
    
    private var bottomLineView = UIView().with({
        $0.backgroundColor = UIColor(rgb: 0x353535)
    })
    
    private let navigationStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)).with({
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .equalCentering
        $0.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, right: -24, bottom: -24)
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
    
    var layoutKind: LayoutKind = .large
    let cardStackContainerView = ContainerView<CardStackView>()
    
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
        
        addSubview(navigationStackView)
        addSubview(cardStackContainerView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topLineView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: 1
        )
        
        bottomLineView.frame = CGRect(
            x: 0,
            y: bounds.height - 1,
            width: bounds.width,
            height: 1
        )
        
        switch layoutKind {
        case .large:
            updateLargeLayoutType()
        case let .compact(height, pin):
            updateCompactLayoutType(
                height: height,
                pin: pin
            )
        }
    }
    
    func perfromApperingAnimation() {
        logotypeView.huetonView.perfromLoadingAnimationAndStartInfinity()
    }
    
    // MARK: Private
    
    private func updateLargeLayoutType() {
        topLineView.alpha = 0
        bottomLineView.alpha = 0
        
        navigationStackView.alpha = 1
        navigationStackView.frame = CGRect(
            x: 24,
            y: safeAreaInsets.top + 16,
            width: max(bounds.width - 48, 300), // max - to hide autolayout warnings
            height: 52
        )
        
        let creditCardParameters = creditCardFrameWithCornerRadius()
        
        cardStackContainerView.frame = creditCardParameters.0
        cardStackContainerView.enclosingView?.cornerRadius = creditCardParameters.1
        cardStackContainerView.enclosingView?.presentation = .large
    }
    
    private func updateCompactLayoutType(
        height: CGFloat,
        pin: LayoutPin
    ) {
        navigationStackView.alpha = 0
        navigationStackView.frame = CGRect(
            x: 24,
            y: (bounds.size.height / 2) - 26,
            width: max(bounds.width - 48, 300), // max - to hide autolayout warnings
            height: 52
        )
        
        cardStackContainerView.enclosingView?.presentation = .compact
        cardStackContainerView.enclosingView?.cornerRadius = 16
        
        switch pin {
        case .top:
            topLineView.alpha = 1
            bottomLineView.alpha = 0
            cardStackContainerView.frame = CGRect(
                x: 12,
                y: 8,
                width: bounds.width - 24,
                height: height - 16
            )
        case .bottom:
            topLineView.alpha = 0
            bottomLineView.alpha = 1
            cardStackContainerView.frame = CGRect(
                x: 12,
                y: bounds.height - height,
                width: bounds.width - 24,
                height: height - 16
            )
        }
    }
    
    private func creditCardFrameWithCornerRadius() -> (CGRect, CGFloat) {
        let insets = UIEdgeInsets(top: navigationStackView.frame.maxY, left: 12, right: 12, bottom: 42)
        
        let maximumWidth = bounds.width - insets.left - insets.right
        let maximumHeight = bounds.height - insets.top - insets.bottom
        
        let ISOHeight = maximumWidth * 1.585772
        let targetHeight = min(maximumHeight, ISOHeight)
        let cornerRadius = targetHeight * 0.0399
        
        let frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: maximumWidth,
            height: targetHeight
        )
        
        return (frame, cornerRadius)
    }
}

extension HuetonView {
    
    static var applicationHeight = CGFloat(20)
}
