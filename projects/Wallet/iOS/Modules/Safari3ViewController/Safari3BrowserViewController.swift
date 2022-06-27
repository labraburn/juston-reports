//
//  Safari3BrowserViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import WebKit
import HuetonUI

protocol Safari3BrowserViewControllerDelegate: AnyObject {
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeURL url: URL?
    )
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        titleDidChange title: String?
    )
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeLoading loading: Bool
    )
}

class Safari3BrowserViewController: UIViewController {
    
    private enum PresentationState {
        
        case error(error: Error)
        case browsing
    }
    
    private lazy var webView = Safari3WebView(
        frame: .zero,
        configuration: WKWeb3Configuration().with({
            $0.dispatcher = self
        })
    ).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsBackForwardNavigationGestures = true
    })
    
    private let errorLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .body)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    })
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private var presentationState: PresentationState = .browsing
    private var urlKeyValueObservation: NSKeyValueObservation?
    private var loadingKeyValueObservation: NSKeyValueObservation?
    private var _url: URL?
    
    override var title: String? {
        get { super.title }
        set {
            super.title = newValue
            delegate?.safari3Browser(
                self,
                titleDidChange: title
            )
        }
    }
    
    weak var delegate: Safari3BrowserViewControllerDelegate?
    
    var url: URL? {
        get { _url }
        set {
            reload(
                using: newValue
            )
        }
    }
    
    var canGoBack: Bool {
        webView.canGoBack
    }
    
    var canGoForward: Bool {
        webView.canGoForward
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view.addSubview(webView)
        view.addSubview(errorLabel)
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate({
            blurView.topAnchor.pin(to: view.topAnchor)
            blurView.pin(horizontally: view)
            blurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)
            
            webView.pin(edges: view)
            errorLabel.pin(
                edges: view.safeAreaLayoutGuide,
                insets: UIEdgeInsets(
                    top: 42,
                    left: 16,
                    bottom: 32,
                    right: 16)
            )
        })
        
        urlKeyValueObservation = webView.observe(
            \.url,
             options: [.new],
             changeHandler: { [weak self] _, change in
                 let url = change.newValue ?? nil
                 guard url != .blank
                 else {
                     return
                 }
                 
                 self?.updateCurrentURL(url)
             }
        )

        loadingKeyValueObservation = webView.observe(
            \.isLoading,
             options: [.new],
             changeHandler: { [weak self] _, change in
                 guard let self = self
                 else {
                     return
                 }
                 
                 self.delegate?.safari3Browser(
                    self,
                    didChangeLoading: change.newValue ?? false
                 )
             }
        )
        
        update(presentationState: presentationState, animated: false)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        webView.customSafeAreaInsets = view.safeAreaInsets
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    private func determinateTitle() {
        let defaultTitle = webView.url?.host
        webView.evaluateJavaScript(
            "document.title",
            completionHandler: { [weak self] object, _ in
                if let text = object as? String, !text.isEmpty {
                    self?.title = text
                } else {
                    self?.title = defaultTitle
                }
            }
        )
    }
    
    private func reload(
        using url: URL?
    ) {
        guard _url != url
        else {
            return
        }
        
        _url = url
        determinateTitle()
        
        guard let url = url
        else {
            return
        }
        
        let request = URLRequest(url: url)
        
        webView.clear()
        webView.load(request)
    }
    
    private func updateCurrentURL(
        _ url: URL?
    ) {
        _url = url
        delegate?.safari3Browser(
            self,
            didChangeURL: url
        )
    }
    
    private func update(
        presentationState: PresentationState,
        animated: Bool
    ) {
        let webViewOpacity = webView.layer.presentation()?.opacity ?? webView.layer.opacity
        webView.layer.removeAllAnimations()
        webView.layer.opacity = webViewOpacity
        
        let errorLabelPpacity = errorLabel.layer.presentation()?.opacity ?? errorLabel.layer.opacity
        errorLabel.layer.removeAllAnimations()
        errorLabel.layer.opacity = errorLabelPpacity
        
        switch self.presentationState {
        case .browsing:
            errorLabel.alpha = 0
        case let .error(error):
            webView.alpha = 0
            errorLabel.text = error.localizedDescription
        }
        
        switch presentationState {
        case .browsing:
            break
        case let .error(error):
            errorLabel.text = error.localizedDescription
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
                self.webView.isHidden = false
            case .error:
                self.webView.isHidden = true
                self.errorLabel.isHidden = false
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
        
        self.presentationState = presentationState
    }
}

extension Safari3BrowserViewController: WKUIDelegate {
    
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

extension Safari3BrowserViewController: WKNavigationDelegate {
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url,
            !url.absoluteString.hasPrefix("http://"),
            !url.absoluteString.hasPrefix("https://"),
            UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .cancel
        } else {
            return .allow
        }
    }
    
    public func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        determinateTitle()
        update(
            presentationState: .browsing,
            animated: true
        )
    }
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        determinateTitle()
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        var _error = error
        if _error.localizedDescription.isEmpty {
            _error = URLError(.unknown)
        }
        
        determinateTitle()
        update(
            presentationState: .error(
                error: _error
            ),
            animated: true
        )
    }
}

extension Safari3BrowserViewController: WKWeb3EventDispatcher {
    
    func dispatch(
        _ response: String
    ) async throws {
        try await webView.dispatch(
            response
        )
    }
}
