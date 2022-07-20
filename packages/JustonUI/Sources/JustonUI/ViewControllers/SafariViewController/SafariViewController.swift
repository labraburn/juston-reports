//
//  Created by Anton Spivak
//

import UIKit
import DeclarativeUI
import WebKit

open class SafariViewController: UIViewController {
    
    public enum Initial {
        
        case url(value: URL)
        case html(value: String)
    }
    
    public enum NavigationItem {
        
        case url
    }

    public enum BottomItem {
        
        case back
        case forward
        case share
        case safari
    }

    private enum PresentationState {
        
        case error(error: Error)
        case browsing
    }

    private let navigationView = SafariViewNavigationView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let bottomItemsView = SafariViewBottomView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private let webView = SafariWebView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insetsLayoutMarginsFromSafeArea = false
        $0.allowsBackForwardNavigationGestures = true
    })

    private let errorLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .jus_textPrimary
        $0.font = .font(for: .body)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    })

    private let initial: Initial

    private let navigationItems: [NavigationItem]
    private let bottomItems: [BottomItem]

    private var presentationState: PresentationState = .browsing

    private var urlKeyValueObservation: NSKeyValueObservation?
    private var loadingKeyValueObservation: NSKeyValueObservation?

    open var tintColor: UIColor? {
        didSet {
            navigationView.tintColor = tintColor
            bottomItemsView.tintColor = tintColor
        }
    }

    public init(
        initial: Initial,
        navigationItems: [NavigationItem] = [.url],
        bottomItems: [BottomItem] = [.back, .forward, .share, .safari]
    ) {
        self.initial = initial

        guard navigationItems.count == Set(navigationItems).count,
              bottomItems.count == Set(bottomItems).count
        else {
            fatalError("Items in \(navigationItems) or \(bottomItems) has duplications.")
        }

        self.navigationItems = navigationItems
        self.bottomItems = bottomItems

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .jus_backgroundPrimary
        webView.navigationDelegate = self
        webView.uiDelegate = self
        bottomItemsView.delegate = self

        view.addSubview(errorLabel)
        view.addSubview(webView)
        view.addSubview(navigationView)
        
        if !bottomItems.isEmpty {
            view.addSubview(bottomItemsView)
        }

        NSLayoutConstraint.activate({
            webView.pin(edges: view)

            errorLabel.pin(vertically: view.safeAreaLayoutGuide, top: 32, bottom: 32)
            errorLabel.pin(horizontally: view.safeAreaLayoutGuide, left: 32, right: 32)

            navigationView.topAnchor.pin(to: view.topAnchor)
            navigationView.pin(horizontally: view)
            
            if !bottomItems.isEmpty {
                bottomItemsView.pin(horizontally: view)
                view.bottomAnchor.pin(to: bottomItemsView.bottomAnchor)
            }
        })

        bottomItemsView.items = bottomItems
        navigationView.items = navigationItems
        
        switch initial {
        case let .url(value):
            let request = URLRequest(url: value)
            webView.load(request)
        case let .html(value):
            webView.loadHTMLString(value, baseURL: nil)
        }

        urlKeyValueObservation = webView.observe(
            \.url,
             options: [.new],
             changeHandler: { [weak self] _, _ in
                 self?.updateBarViews()
             }
        )

        loadingKeyValueObservation = webView.observe(
            \.isLoading,
             options: [.new],
             changeHandler: { [weak self] _, change in
                 self?.navigationView.isLoading = change.newValue ?? false
                 self?.updateBarViews()
             }
        )
        
        tintColor = .jus_letter_purple
        update(presentationState: presentationState, animated: false)
        updateBarViews()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var additionalSafeAreaInsets = UIEdgeInsets(
            top: navigationView.frame.maxY,
            left: 0,
            bottom: view.safeAreaInsets.bottom,
            right: 0
        )
        
        if bottomItemsView.superview == view {
            additionalSafeAreaInsets.bottom = view.bounds.height - bottomItemsView.frame.minY
        }

        guard webView.additionalSafeAreaInsets != additionalSafeAreaInsets
        else {
            return
        }

        webView.additionalSafeAreaInsets = additionalSafeAreaInsets
    }

    // MARK: Private

    private func updateBarViews() {
        (bottomItemsView.view(for: .back) as? UIButton)?.isEnabled = webView.canGoBack
        (bottomItemsView.view(for: .forward) as? UIButton)?.isEnabled = webView.canGoForward

        let titleLabel = navigationView.view(for: .url) as? UILabel
        titleLabel?.text = webView.url?.host
        webView.evaluateJavaScript("document.title", completionHandler: { [weak titleLabel] object, _ in
            guard let text = object as? String,
                  !text.isEmpty
            else {
                return
            }

            titleLabel?.text = text
        })
    }

    private func update(
        presentationState: PresentationState,
        animated: Bool
    ) {
        switch self.presentationState {
        case .browsing:
            self.errorLabel.alpha = 0
        case .error:
            self.webView.alpha = 0
        }
        
        self.errorLabel.isHidden = false
        self.webView.isHidden = false
        
        let animations = {
            switch presentationState {
            case .browsing:
                self.errorLabel.alpha = 0
                self.webView.alpha = 1
            case .error:
                self.errorLabel.alpha = 1
                self.webView.alpha = 0
            }
        }
        
        let completion = { (_ finished: Bool) in
            switch presentationState {
            case .browsing:
                self.errorLabel.isHidden = true
            case .error:
                self.webView.isHidden = true
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.42,
                delay: 0,
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
        
        switch presentationState {
        case let .error(error):
            webView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = error.localizedDescription
        case .browsing:
            webView.isHidden = false
            errorLabel.isHidden = true
        }
    }
}

extension SafariViewController: WKUIDelegate {
    
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
}

extension SafariViewController: WKNavigationDelegate {
    
    open func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        .allow
    }
    
    open func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        update(
            presentationState: .browsing,
            animated: true
        )
        
        updateBarViews()
    }

    open func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        update(
            presentationState: .error(error: error),
            animated: true
        )
        
        updateBarViews()
    }
}

extension SafariViewController: SafariViewBottomViewDelegate {
    
    func safariViewBottomView(_ view: SafariViewBottomView, didSelectItem item: BottomItem) {
        switch item {
        case .back:
            webView.goBack()
        case .forward:
            webView.goForward()
        case .share:
            guard let url = webView.url
            else {
                break
            }

            let activityController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            jus_present(activityController, animated: true)
        case .safari:
            guard let url = webView.url
            else {
                break
            }

            UIApplication.shared.open(
                url,
                options: [.universalLinksOnly: false]
            )
        }
    }
}
