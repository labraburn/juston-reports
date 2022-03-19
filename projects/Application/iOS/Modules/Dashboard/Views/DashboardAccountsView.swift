//
//  DashboardAccountsView.swift
//  iOS
//
//  Created by Anton Spivak on 12.03.2022.
//

import UIKit
import BilftUI

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
}

final class DashboardAccountsView: UIView, DashboardCollectionHeaderSubview {
    
    private var safeAreaView = UIView()
    private var logoView = AnimatedLogoView()
    private let stackView = DashboardStackView()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let logoViewReloadOffset = CGFloat(44)
    private let logoViewDefaultOffset = CGFloat(24)
    private var logoViewAdditionalOffset = CGFloat(0)
    private var isAbleToRefreshAnimation = true
    
    weak var delegate: DashboardAccountsViewDelegate?
    
    var compacthHeight: CGFloat { 93 }
    var selected: DashboardStackView.Model? { stackView.selected }
    
    private(set) var isLoading: Bool = false
    
    var cards: [DashboardStackView.Model] {
        get { stackView.data }
        set { stackView.update(data: newValue, selected: nil, animated: true) }
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
        backgroundColor = .bui_backgroundSecondary
        
        safeAreaView.backgroundColor = .bui_backgroundSecondary
        addSubview(safeAreaView)
        
        logoView.update(presentation: .on)
        logoView.backgroundColor = .clear
        addSubview(logoView)
        
        stackView.delegate = self
        addSubview(stackView)
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
            additionalInsets: CreditCardParameters.defaultAdditionalInsetsForAnimatedLogoViewWithSafeAreaInsets(safeAreaInsets)
        ).calculate()
        
        stackView.frame = creditCardParameters.topUpCreditCardFrame
        stackView.cornerRadius = creditCardParameters.cornerRadius
        stackView.presentation = .large
    }
    
    private func updateCompactLayoutType() {
        logoView.alpha = 0
        
        stackView.frame = CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height)
        stackView.presentation = .compact
        stackView.cornerRadius = 16
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
