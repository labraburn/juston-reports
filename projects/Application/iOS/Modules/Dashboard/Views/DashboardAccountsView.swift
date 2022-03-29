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
        didChangeSelectedModel model: DashboardStackView.Model
    )
    
    func dashboardAccountsView(
        _ view: DashboardAccountsView,
        addAccountButtonDidClick button: UIButton
    )
}

final class DashboardAccountsView: UIView, DashboardCollectionHeaderSubview {
    
    private var safeAreaView = UIView()
    private var logoView = AnimatedLogoView()
    private let stackView = DashboardStackView()
    private let bottomHStackView = UIStackView()
    
    private lazy var bottomAddAccountButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleDownAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.widthAnchor.pin(to: 52).isActive = true
        $0.heightAnchor.pin(to: 52).isActive = true
        $0.setImage(.hui_addCircle24, for: .normal)
        $0.addTarget(self, action: #selector(bottomAddAccountButtonDidClick(_:)), for: .touchUpInside)
        $0.tintColor = .hui_textPrimary
    })
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let logoViewReloadOffset = CGFloat(44)
    private let logoViewDefaultOffset = CGFloat(24)
    private var logoViewAdditionalOffset = CGFloat(0)
    private var isAbleToRefreshAnimation = true
    
    weak var delegate: DashboardAccountsViewDelegate?
    
    var compacthHeight: CGFloat { 103 }
    var selected: DashboardStackView.Model? { stackView.selected }
    
    private(set) var isLoading: Bool = false
    
    var cards: [DashboardStackView.Model] {
        stackView.data
    }
    
    var refreshControlText: String? {
        get { logoView.text }
        set { logoView.text = newValue }
    }
    
    var refreshControlPresentation: AnimatedLogoView.Presentation {
        get { logoView.presentation }
        set { logoView.update(presentation: newValue) }
    }
    
    var layoutType: DashboardCollectionHeaderView.LayoutType = .init(bounds: .zero, safeAreaInsets: .zero, kind: .large) {
        didSet {
            guard layoutType != oldValue
            else {
                return
            }
            
            isAbleToRefreshAnimation = false
            updateLayout()
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .hui_backgroundPrimary
        
        safeAreaView.backgroundColor = .hui_backgroundPrimary
        addSubview(safeAreaView)
        
        logoView.update(presentation: .on)
        logoView.backgroundColor = .clear
        addSubview(logoView)
        
        stackView.delegate = self
        addSubview(stackView)
        
        bottomHStackView.addArrangedSubview(bottomAddAccountButton)
        addSubview(bottomHStackView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        logoView.prepareLoadingAnimation(with: progress)
        
        if additionalOffset > logoViewReloadOffset && scrollView.isTracking {
            startLoadingAnimationIfNeccessary()
        }
    }
    
    func set(cards: [DashboardStackView.Model], selected: DashboardStackView.Model?, animated: Bool) {
        stackView.update(data: cards, selected: selected, animated: animated)
    }
    
    // MARK: Private
    
    private func startLoadingAnimationIfNeccessary() {
        guard !isLoading, (delegate?.dashboardAccountsViewShouldStartRefreshing(self) ?? false)
        else {
            return
        }
        
        isLoading = true
        
        logoView.startLoadingAnimation()
        
        feedbackGenerator.impactOccurred()
        delegate?.dashboardAccountsViewDidStartRefreshing(self)
    }
    
    private func stopLoadingAnimationIfNeccessary() {
        guard isLoading
        else {
            return
        }
        
        logoView.stopLoadingAnimation()
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
        
        updateBottomHStackViewLayout()
    }
    
    private func updateLogoViewLayout() {
        logoView.frame = CGRect(
            x: (bounds.width - AnimatedLogoView.applicationWidth) / 2,
            y: -logoViewAdditionalOffset,
            width: AnimatedLogoView.applicationWidth,
            height: AnimatedLogoView.applicationHeight
        )
    }
    
    private func updateLargeLayoutType() {
        let safeAreaInsets = layoutType.safeAreaInsets
        
        if !isLoading {
            UIView.performWithoutAnimation({
                logoView.update(presentation: .on)
            })
        }
        
        logoView.alpha = 1
        updateLogoViewLayout()
        
        let creditCardParameters = CreditCardParameters(
            rect: bounds,
            safeAreaInsets: .zero,
            additionalInsets: defaultAdditionalInsetsWithSafeAreaInsets(safeAreaInsets)
        ).calculate()
        
        stackView.frame = creditCardParameters.topUpCreditCardFrame
        stackView.cornerRadius = creditCardParameters.cornerRadius
        stackView.presentation = .large
        
        bottomHStackView.alpha = 1
        updateBottomHStackViewLayout()
    }
    
    private func updateCompactLayoutType() {
        logoView.alpha = 0
        
        stackView.frame = CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height)
        stackView.presentation = .compact
        stackView.cornerRadius = 16
        
        bottomHStackView.alpha = 0
    }
    
    private func updateBottomHStackViewLayout() {
        let height = CGFloat(52)
        bottomHStackView.frame = CGRect(
            x: 12,
            y: bounds.height - height - 12,
            width: bounds.width - 24,
            height: height
        )
    }
    
    private func defaultAdditionalInsetsWithSafeAreaInsets(_ safeAreaInsets: UIEdgeInsets) -> UIEdgeInsets {
        let bottom: CGFloat = 76 + (safeAreaInsets.bottom == 0 ? 42 : 24) // 76 - bottom h stack view
        return UIEdgeInsets(
            top: AnimatedLogoView.applicationHeight + 24,
            left: 12,
            bottom: bottom,
            right: 12
        )
    }
    
    // MARK: Actions
    
    @objc
    private func bottomAddAccountButtonDidClick(_ sender: UIButton) {
        delegate?.dashboardAccountsView(self, addAccountButtonDidClick: sender)
    }
}

extension DashboardAccountsView: DashboardStackViewDelegate {
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didChangeSelectedModel model: DashboardStackView.Model
    ) {
        delegate?.dashboardAccountsView(self, didChangeSelectedModel: model)
    }
}
