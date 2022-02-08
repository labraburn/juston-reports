//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

open class HeaderPageViewController: UIPageViewController {
    public enum HeaderSizingRule {
        case dynamic(minimumHeight: CGFloat)
        case bottomStretchable(pinTopSafeArea: Bool)
        case `static`(pinToTopIfRefreshControl: Bool)
    }

    open var headerViewController: UIViewController? {
        headerPageViewController
    }

    open var isScrollEnabled: Bool {
        get { queueScrollView().isScrollEnabled }
        set { queueScrollView().isScrollEnabled = newValue }
    }

    private var headerViewTopConstraint: NSLayoutConstraint?
    private var headerViewHeightConstraint: NSLayoutConstraint?
    private var headerViewBottomConstraint: NSLayoutConstraint?

    private var headerPageViewController: UIViewController?
    private var headerPageViewControllerSizingRule: HeaderSizingRule = .dynamic(minimumHeight: 0)
    private var headerView = HeaderPageViewControllerHeaderView()

    private var boundsKeyValueObservation: NSKeyValueObservation?

    private var cachedHeaderViewControllerOffset: CGFloat = .zero
    private var cachedHeaderViewControllerMaximumHeight: CGFloat = .zero

    public init(options: [UIPageViewController.OptionsKey: Any]? = nil) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: options
        )
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        boundsKeyValueObservation?.invalidate()
        boundsKeyValueObservation = nil
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCurrentOverridableResponder()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        queueScrollView().sui_contentOffsetAnimationDuration = 0.21

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: view.topAnchor)
        headerViewTopConstraint?.isActive = true

        headerViewBottomConstraint = view.bottomAnchor.constraint(
            greaterThanOrEqualTo: headerView.bottomAnchor,
            constant: 0
        )

        headerViewBottomConstraint?.priority = .defaultLow
        headerViewBottomConstraint?.isActive = true

        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 0)
        headerViewHeightConstraint?.priority = .defaultLow
        headerViewHeightConstraint?.isActive = true

        boundsKeyValueObservation = queueScrollView().observe(\.bounds, changeHandler: { [weak self] _, _ in
            self?.updateCurrentOverridableResponder()
        })
    }

    // MARK: UIViewController+SUI

    override open func sui_updateUnclampedContentInsetsForChildrenIfNeccessary() {
        super.sui_updateUnclampedContentInsetsForChildrenIfNeccessary()

        let headerViewTargetSize = headerView.wrappedViewTargetSize
        let topYOffset = headerViewTopConstraint?.constant ?? 0

        let unclampedInsets = SUIUnclampedInsets(
            insets: UIEdgeInsets(
                top: -topYOffset,
                left: 0,
                bottom: 0,
                right: 0
            ),
            range: SUIFloatRange(
                location: 0,
                length: headerViewTargetSize.height
            )
        )

        let overlayInsets = UIEdgeInsets(
            top: max(headerViewTargetSize.height - view.safeAreaInsets.top, .zero),
            left: 0,
            bottom: 0,
            right: 0
        )

        sui_overlayContentInsets = overlayInsets
        sui_unclampedContentInsets = unclampedInsets

        // swiftlint:disable:next contains_over_filter_is_empty
        if children.filter({ $0 != headerViewController }).isEmpty {
            updateHeaderViewControllerHeightToMatchContentOffset(with: .zero)
        }
    }

    override open func sui_shouldApplyUnclampedContentInsets(
        toChildViewController childViewController: UIViewController
    ) -> Bool {
        guard childViewController != headerViewController
        else {
            return false
        }

        return true
    }

    // MARK: UIPageViewController+SUI

    override open func sui_scrollViewObserver(for scrollView: UIScrollView) -> UISUIScrollViewObserver? {
        self
    }

    override open func sui_queue(_ scrollView: UIScrollView, willManualScrollTo toViewController: UIViewController) {
        super.sui_queue(scrollView, willManualScrollTo: toViewController)
        toViewController.sui_contentScrollView()?.sui_adjustContentOffsetIfNecessary()
    }

    // MARK: Public API

    public func setHeaderViewController(_ viewController: UIViewController, with sizingRule: HeaderSizingRule) {
        headerPageViewControllerSizingRule = sizingRule
        updateHeaderViewController(viewController, previousViewController: headerPageViewController)
    }

    // MARK: Private

    private func queueScrollView() -> UIScrollView {
        var scrollView: UIView?
        view.subviews.forEach { subview in
            if subview.isKind(of: UIScrollView.self) {
                scrollView = subview
            }
        }

        guard let scrollView = scrollView as? UIScrollView
        else {
            fatalError("Can't find internal scroll view.")
        }

        return scrollView
    }

    private func activeViewController() -> UIViewController? {
        let scrollView = queueScrollView()
        let point = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let converted = view.convert(point, to: scrollView)

        let hit = scrollView.hitTest(converted, with: nil)

        var wrapperViewController: UIViewController?
        var responder: UIResponder? = hit

        while responder != nil && wrapperViewController == nil {
            if let viewController = responder as? UIViewController {
                wrapperViewController = viewController
            }

            responder = responder?.next
        }

        return wrapperViewController
    }

    private func updateHeaderViewController(
        _ viewController: UIViewController?,
        previousViewController: UIViewController?
    ) {
        guard previousViewController != viewController
        else {
            return
        }

        previousViewController?.willMove(toParent: nil)
        previousViewController?.view.removeFromSuperview()
        previousViewController?.removeFromParent()

        guard let headerViewController = viewController
        else {
            return
        }

        guard !headerViewController.view.translatesAutoresizingMaskIntoConstraints
        else {
            fatalError(
                "Header view controllers's view should be `translatesAutoresizingMaskIntoConstraints` as `false`"
            )
        }

        addChild(headerViewController)
        headerView.wrappedView = headerViewController.view
        headerViewController.didMove(toParent: self)

        headerPageViewController = viewController
    }

    private func updateCurrentOverridableResponder() {
        let overridenNextResponder = activeViewController()?.sui_contentScrollView()
        headerView.overrideNextResponder(with: overridenNextResponder)
    }

    private func updateHeaderViewControllerHeightToMatchContentOffset(
        in scrollView: UIScrollView,
        with contentOffset: CGPoint
    ) {
        let maximumHeight = headerView.wrappedViewTargetSize.height
        let offset = scrollView.contentInset.top - contentOffset.y - maximumHeight

        updateHeaderViewControllerHeightToMatchContentOffset(
            with: offset,
            refreshControl: scrollView.refreshControl
        )
    }

    private func updateHeaderViewControllerHeightToMatchContentOffset(
        with offset: CGFloat,
        refreshControl: UIRefreshControl? = nil
    ) {
        let maximumHeight = headerView.wrappedViewTargetSize.height

        guard offset != cachedHeaderViewControllerOffset ||
            maximumHeight != cachedHeaderViewControllerMaximumHeight
        else {
            return
        }

        let queueScrollView = queueScrollView()

        guard !queueScrollView.isTracking,
              !queueScrollView.isDragging,
              !queueScrollView.isDecelerating
        else {
            return
        }

        guard offset != 0
        else {
            headerViewTopConstraint?.constant = offset
            headerViewHeightConstraint?.priority = .defaultLow
            viewIfLoaded?.layoutIfNeeded()
            return
        }

        switch headerPageViewControllerSizingRule {
        case let .dynamic(minimumHeight):
            headerViewTopConstraint?.constant = 0
            headerViewHeightConstraint?.priority = .defaultHigh
            if offset < 0 {
                if (maximumHeight + offset) > minimumHeight {
                    headerViewHeightConstraint?.constant = maximumHeight + offset
                }
                else {
                    headerViewHeightConstraint?.constant = minimumHeight
                }
            }
            else {
                headerViewHeightConstraint?.constant = maximumHeight + offset
            }
        case let .bottomStretchable(pinTopSafeArea):
            if offset < 0 {
                var minimumConstant = -maximumHeight
                if pinTopSafeArea {
                    minimumConstant += view.safeAreaInsets.top
                }

                headerViewTopConstraint?.constant = offset < minimumConstant ? minimumConstant : offset
                headerViewHeightConstraint?.priority = .defaultLow
            }
            else {
                headerViewTopConstraint?.constant = 0
                headerViewHeightConstraint?.priority = .defaultHigh
                headerViewHeightConstraint?.constant = maximumHeight + offset
            }
        case let .static(pinToTopIfRefreshControl):
            var maximumOffset = offset
            if offset > 0 && pinToTopIfRefreshControl && refreshControl != nil {
                maximumOffset = 0
            }

            headerViewTopConstraint?.constant = offset < -maximumHeight ? -maximumHeight : maximumOffset
            headerViewHeightConstraint?.priority = .defaultLow
        }

        cachedHeaderViewControllerMaximumHeight = maximumHeight
        cachedHeaderViewControllerOffset = offset

        viewIfLoaded?.layoutIfNeeded()
    }
}

extension HeaderPageViewController: UISUIScrollViewObserver {
    public func scrollViewDidChangeContentOffset(
        _ scrollView: UIScrollView,
        contentOffset: CGPoint,
        previousContentOffset: CGPoint
    ) {
        updateHeaderViewControllerHeightToMatchContentOffset(in: scrollView, with: contentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {}
}
