//
//  Safari3BrowserViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import WebKit
import HuetonUI

class Safari3BrowserViewController: UIViewController {
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let webView = WKWebView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsBackForwardNavigationGestures = true
    })
    
    private var urlKeyValueObservation: NSKeyValueObservation?
    private var loadingKeyValueObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(webView)
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate({
            blurView.topAnchor.pin(to: view.topAnchor)
            blurView.pin(horizontally: view)
            blurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)
            
            webView.pin(edges: view)
        })
        
        urlKeyValueObservation = webView.observe(
            \.url,
             options: [.new],
             changeHandler: { [weak self] _, _ in
//                 self?.updateBarViews()
             }
        )

        loadingKeyValueObservation = webView.observe(
            \.isLoading,
             options: [.new],
             changeHandler: { [weak self] _, change in
//                 self?.navigationView.isLoading = change.newValue ?? false
//                 self?.updateBarViews()
             }
        )
    }
}
