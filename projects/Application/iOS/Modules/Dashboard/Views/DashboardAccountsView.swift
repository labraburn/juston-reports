//
//  DashboardAccountsView.swift
//  iOS
//
//  Created by Anton Spivak on 12.03.2022.
//

import UIKit
import HuetonUI

protocol DashboardAccountsViewDelegate: AnyObject {
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        addAccountButtonDidClick button: UIButton
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        scanQRButtonDidClick button: UIButton
    )
}

extension HuetonView {
    
    static var applicationHeight = CGFloat(20)
}

final class DashboardAccountsView: UIView, DashboardCollectionHeaderSubview {
    
    private var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(radius: 42))
    private var lineView = UIView().with({
        $0.backgroundColor = UIColor(rgb: 0x353535)
    })
    
    private let cardsStackContainerView = ContainerView<CardStackView>()
    
    private let navigationStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)).with({
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .equalCentering
    })
    
    private var huetonView = HuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private var logoViewAdditionalOffset = CGFloat(0)
    private var cachedBounds = CGRect.zero
    
    weak var delegate: DashboardAccountsViewDelegate?
    
    internal let compacthHeight = CGFloat(135)
    
    var layoutType: DashboardCollectionHeaderView.LayoutType = .init(bounds: .zero, safeAreaInsets: .zero, kind: .large)
    var cardStackView: CardStackView? {
        get { cardsStackContainerView.enclosingView }
        set { cardsStackContainerView.enclosingView = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        addSubview(visualEffectView)
        addSubview(lineView)
        
        navigationStackView.addArrangedSubview({
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.insertHighlightingScaleAnimation()
            button.insertFeedbackGenerator(style: .light)
            button.sui_touchAreaInsets = UIEdgeInsets(top: 0, left: -24, right: -24, bottom: -24)
            button.setImage(.hui_scan20, for: .normal)
            button.addTarget(self, action: #selector(scanQRButtonDidClick(_:)), for: .touchUpInside)
            button.tintColor = .hui_textPrimary
            return button
        }())
        navigationStackView.addArrangedSubview({
            let wrapperView = UIView()
            wrapperView.addSubview(huetonView)
            wrapperView.heightAnchor.pin(to: HuetonView.applicationHeight).isActive = true
            huetonView.pinned(edges: wrapperView)
            return wrapperView
        }())
        navigationStackView.addArrangedSubview({
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.insertHighlightingScaleAnimation()
            button.insertFeedbackGenerator(style: .light)
            button.sui_touchAreaInsets = UIEdgeInsets(top: 0, left: -24, right: -24, bottom: -24)
            button.setImage(.hui_addCircle20, for: .normal)
            button.addTarget(self, action: #selector(addAccountButtonDidClick(_:)), for: .touchUpInside)
            button.tintColor = .hui_textPrimary
            return button
        }())
        navigationStackView.backgroundColor = .hui_backgroundPrimary
        
        addSubview(navigationStackView)
        addSubview(cardsStackContainerView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds != cachedBounds,
              bounds.height > 1 // handle estimated collection view height
        else {
            return
        }
        
        cachedBounds = bounds
        updateLayout()
    }
    
    // MARK: API
    
    func perfromApperingAnimation() {
        huetonView.perfromLoadingAnimationAndStartInfinity()
    }
    
    func enclosingScrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        
        logoViewAdditionalOffset = max(-contentOffset / 2, 0)
        updateLogoViewLayout()
    }
    
    private func updateLayout() {
        let safeAreaInsets = layoutType.safeAreaInsets
        visualEffectView.frame = CGRect(
            x: -safeAreaInsets.left,
            y: -safeAreaInsets.top,
            width: bounds.width + safeAreaInsets.left + safeAreaInsets.right,
            height: bounds.height + safeAreaInsets.top - 18
        )
        
        lineView.frame = CGRect(
            x: 0,
            y: visualEffectView.frame.maxY - 1,
            width: bounds.width,
            height: 1
        )
        
        switch layoutType.kind {
        case .large:
            updateLargeLayoutType()
        case .compact:
            updateCompactLayoutType()
        }
    }
    
    private func updateLogoViewLayout() {
        navigationStackView.frame = CGRect(
            x: 24,
            y: 16 - logoViewAdditionalOffset,
            width: max(bounds.width - 48, 300), // max - to hide autolayout warnings
            height: 52
        )
    }
    
    private func updateLargeLayoutType() {
        lineView.alpha = 0
        
        navigationStackView.alpha = 1
        updateLogoViewLayout()
        
        let creditCardParameters = creditCardFrameWithCornerRadius()
        
        cardsStackContainerView.frame = creditCardParameters.0
        cardsStackContainerView.enclosingView?.cornerRadius = creditCardParameters.1
        cardsStackContainerView.enclosingView?.presentation = .large
    }
    
    private func updateCompactLayoutType() {
        navigationStackView.alpha = 0
        lineView.alpha = 1
        
        cardsStackContainerView.frame = CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height - 32)
        cardsStackContainerView.enclosingView?.presentation = .compact
        cardsStackContainerView.enclosingView?.cornerRadius = 16
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
    
    // MARK: Actions
    
    @objc
    private func addAccountButtonDidClick(_ sender: UIButton) {
        delegate?.dashboardAccountsView(self, addAccountButtonDidClick: sender)
    }
    
    @objc
    private func scanQRButtonDidClick(_ sender: UIButton) {
        delegate?.dashboardAccountsView(self, scanQRButtonDidClick: sender)
    }
}
