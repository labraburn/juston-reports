//
//  Web3ViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI
import WebKit

class Web3ViewController: UIViewController {
    
    private enum Web3ViewPresentation {
        
        case error(error: Error)
        case browsing
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle { get { .pageSheet } set { let _ = newValue } }
    override var isModalInPresentation: Bool {  get { false } set { let _ = newValue }  }
    
    private let navigationView = Web3NavigationView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let webView = Web3WebView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insetsLayoutMarginsFromSafeArea = false
        $0.allowsBackForwardNavigationGestures = true
    })
    
    private let errorLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .body)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    })
    
    private(set) var url: URL
    
    open var tintColor: UIColor? {
        didSet {
            navigationView.tintColor = tintColor
        }
    }

    private var urlKeyValueObservation: NSKeyValueObservation?
    private var loadingKeyValueObservation: NSKeyValueObservation?
    private var progressKeyValueObservation: NSKeyValueObservation?
    
    public init(
        url: URL
    ) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.delegate = self
        
        view.backgroundColor = .hui_backgroundPrimary
        webView.navigationDelegate = self

        view.addSubview(errorLabel)
        view.addSubview(webView)
        view.addSubview(navigationView)

        NSLayoutConstraint.activate({
            webView.pin(edges: view)

            errorLabel.pin(vertically: view.safeAreaLayoutGuide, top: 32, bottom: 32)
            errorLabel.pin(horizontally: view.safeAreaLayoutGuide, left: 32, right: 32)
            
            navigationView.topAnchor.pin(to: view.topAnchor)
            navigationView.pin(horizontally: view)
        })
        
        let request = URLRequest(url: url)
        webView.load(request)

        urlKeyValueObservation = webView.observe(\.url, changeHandler: { [weak self] _, _ in
            self?.matchViewWithCurrentStateIfNeeded()
        })

        loadingKeyValueObservation = webView.observe(\.isLoading, changeHandler: { [weak self] _, change in
            self?.navigationView.isLoading = change.newValue ?? false
            self?.matchViewWithCurrentStateIfNeeded()
        })

        progressKeyValueObservation = webView.observe(\.estimatedProgress, changeHandler: { [weak self] _, change in
            self?.navigationView.progress = Float(change.newValue ?? 0)
        })
        
        update(with: .browsing)
        matchViewWithCurrentStateIfNeeded()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = UIEdgeInsets(
            top: navigationView.frame.maxY,
            left: 0,
            bottom: 0,
            right: 0
        )

        guard webView.customSafeAreaInsets != safeAreaInsets
        else {
            return
        }

        webView.customSafeAreaInsets = safeAreaInsets
    }
    
    // MARK: Private
    
    private func matchViewWithCurrentStateIfNeeded() {
        navigationView.title = webView.url?.host
        webView.evaluateJavaScript("document.title", completionHandler: { [weak navigationView] object, _ in
            guard let text = object as? String,
                  !text.isEmpty
            else {
                return
            }

            navigationView?.title = text
        })
    }
    
    private func update(with presentation: Web3ViewPresentation) {
        switch presentation {
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

extension Web3ViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        update(with: .browsing)
        matchViewWithCurrentStateIfNeeded()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        update(with: .error(error: error))
        matchViewWithCurrentStateIfNeeded()
    }
}

extension Web3ViewController: Web3NavigationViewDelegate {
    
    func web3NavigationView(_ view: Web3NavigationView, didClickCloseButton sender: UIControl) {
        dismiss(animated: true)
    }
}
