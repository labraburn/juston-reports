//
//  DashboardAccountsView.swift
//  iOS
//
//  Created by Anton Spivak on 12.03.2022.
//

import UIKit
import HuetonUI

protocol DashboardAccountsViewDelegate: AnyObject {
    
    func dashboardAccountsViewShouldStartRefreshing(
        _ view: DashboardAccountsView
    ) -> Bool
    
    func dashboardAccountsViewDidStartRefreshing(
        _ view: DashboardAccountsView
    )
    
    func dashboardAccountsViewIsUserInteractig(
        _ view: DashboardAccountsView
    ) -> Bool
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        addAccountButtonDidClick button: UIButton
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        scanQRButtonDidClick button: UIButton
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didChangeSelectedModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickRemoveButtonWithModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickSendButtonWithModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickReceiveButtonWithModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickSubscribeButtonWithModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        didClickUnsubscribeButtonWithModel model: DashboardStackView.Model
    )
}

final class DashboardAccountsView: UIView, DashboardCollectionHeaderSubview {
    
    private var safeAreaView = UIView()
    
    private let cardsStackView = DashboardStackView()
    
    private let navigationStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)).with({
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .equalCentering
    })
    
    private var huetonView = DashboardHuetonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let logoViewReloadOffset = CGFloat(44)
    private let logoViewDefaultOffset = CGFloat(24)
    private var logoViewAdditionalOffset = CGFloat(0)
    private var isAbleToRefreshAnimation = true
    private var cachedBounds = CGRect.zero
    
    weak var delegate: DashboardAccountsViewDelegate?
    
    var compacthHeight: CGFloat { 103 }
    var selected: DashboardStackView.Model? { cardsStackView.selected }
    
    private(set) var isLoading: Bool = false
    
    var cards: [DashboardStackView.Model] {
        cardsStackView.data
    }
    
    var huetonViewText: String? {
        get { huetonView.text }
        set { huetonView.text = newValue }
    }
    
    var layoutType: DashboardCollectionHeaderView.LayoutType = .init(bounds: .zero, safeAreaInsets: .zero, kind: .large) {
        didSet {
            guard layoutType != oldValue
            else {
                return
            }
            
            isAbleToRefreshAnimation = false
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .hui_backgroundPrimary
        
        safeAreaView.backgroundColor = .hui_backgroundPrimary
        addSubview(safeAreaView)
        
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
        
        cardsStackView.delegate = self
        addSubview(cardsStackView)
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
    
    func startLoadingAnimationIfAvailable() {
        startLoadingAnimationIfNeccessary()
    }
    
    func stopLoadingIfAvailable() {
        stopLoadingAnimationIfNeccessary()
    }
    
    func enclosingScrollViewWillStartDraging(_ scrollView: UIScrollView) {
        isAbleToRefreshAnimation = true
    }
    
    func enclosingScrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        
        logoViewAdditionalOffset = max(-contentOffset / 2, 0)
        updateLogoViewLayout()
        
        guard !isLoading, isAbleToRefreshAnimation, layoutType.kind == .large
        else {
            return
        }
        
        let additionalOffset = -contentOffset / 2
        let progress = additionalOffset / logoViewReloadOffset
        huetonView.set(progress: progress)
        
        if additionalOffset > logoViewReloadOffset && scrollView.isTracking {
            startLoadingAnimationIfNeccessary()
        }
    }
    
    func set(cards: [DashboardStackView.Model], selected: DashboardStackView.Model?, animated: Bool) {
        cardsStackView.update(data: cards, selected: selected, animated: animated)
    }
    
    // MARK: Private
    
    private func startLoadingAnimationIfNeccessary() {
        guard !isLoading, (delegate?.dashboardAccountsViewShouldStartRefreshing(self) ?? false)
        else {
            return
        }
        
        isLoading = true
        isAbleToRefreshAnimation = false
        
        huetonView.startInfinityAnimation()
        feedbackGenerator.impactOccurred()
        
        delegate?.dashboardAccountsViewDidStartRefreshing(self)
    }
    
    private func stopLoadingAnimationIfNeccessary() {
        guard isLoading
        else {
            return
        }
        
        huetonView.stopInfinityAnimation()
        isLoading = false
    }
    
    private func updateLayout() {
        let safeAreaInsets = layoutType.safeAreaInsets
        safeAreaView.frame = CGRect(
            x: -safeAreaInsets.left,
            y: -safeAreaInsets.top,
            width: bounds.width + safeAreaInsets.left + safeAreaInsets.right,
            height: safeAreaInsets.top
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
        if !isLoading {
            UIView.performWithoutAnimation({
                huetonView.performUpdatesWithLetters { $0.on() }
            })
        }
        
        navigationStackView.alpha = 1
        updateLogoViewLayout()
        
        let creditCardParameters = creditCardFrameWithCornerRadius()
        
        cardsStackView.frame = creditCardParameters.0
        cardsStackView.cornerRadius = creditCardParameters.1
        cardsStackView.presentation = .large
    }
    
    private func updateCompactLayoutType() {
        navigationStackView.alpha = 0
        
        cardsStackView.frame = CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height)
        cardsStackView.presentation = .compact
        cardsStackView.cornerRadius = 16
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

extension DashboardAccountsView: DashboardStackViewDelegate {
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didChangeSelectedModel model: DashboardStackView.Model
    ) {
        huetonView.account = model.account
        delegate?.dashboardAccountsView(self, didChangeSelectedModel: model)
    }
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didClickRemoveButtonWithModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didClickRemoveButtonWithModel: model)
    }
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didClickSendButtonWithModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didClickSendButtonWithModel: model)
    }
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didClickReceiveButtonWithModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didClickReceiveButtonWithModel: model)
    }
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didClickSubscribeButtonWithModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didClickSubscribeButtonWithModel: model)
    }
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didClickUnsubscrabeButtonWithModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didClickUnsubscribeButtonWithModel: model)
    }
}
