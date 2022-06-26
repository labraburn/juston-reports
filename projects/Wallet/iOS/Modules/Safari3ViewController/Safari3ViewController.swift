//
//  Safari3ViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.06.2022.
//

import UIKit
import WebKit
import HuetonUI
import HuetonCORE

class Safari3ViewController: UIViewController {
    
    enum NavigationAction {
        
        case back
        case forward
        case addFavourite
        case removeFavourite
        case share
        case reload
    }
    
    override var childForStatusBarStyle: UIViewController? { currentViewController }
    override var childForHomeIndicatorAutoHidden: UIViewController? { currentViewController }
    override var childForStatusBarHidden: UIViewController? { currentViewController }
    override var childViewControllerForPointerLock: UIViewController? { currentViewController }
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? { currentViewController }
    
    private let browserViewController = Safari3BrowserViewController()
    private let bookmarksViewController = Safari3BookmarksViewController()
    private let welcomeViewController = Safari3WelcomeViewController()
    
    private var currentViewController: UIViewController? {
        children.first
    }
    
    private weak var navigationView: AccountStackBrowserNavigationView?
    
    var account: PersistenceAccount? = nil {
        didSet {
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        browserViewController.delegate = self
        
        showBrowserElseWelcome(
            animated: false
        )
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    func attach(_ view: AccountStackBrowserNavigationView) {
        navigationView = view
        navigationView?.delegate = self
        navigationView?.setActiveURL(nil)
    }
    
    private func showBrowserElseWelcome(
        animated: Bool
    ) {
        switch browserViewController.url {
        case .none:
            show(welcomeViewController, animated: animated)
        case .some:
            show(browserViewController, animated: animated)
        }
    }
    
    private func show(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        let previousViewController = currentViewController
        guard viewController != previousViewController
        else {
            return
        }
        
        previousViewController?.willMove(toParent: nil)
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.pinned(edges: view)
        viewController.view.alpha = 0
        
        let animations = {
            previousViewController?.view.alpha = 0
            viewController.view.alpha = 1
            
            self.updateAppearance(animated: false)
        }
        
        let completion = { (finished: Bool) in
            viewController.didMove(toParent: self)
            previousViewController?.view.removeFromSuperview()
            previousViewController?.removeFromParent()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
    
    private func updateAppearance(
        animated: Bool,
        duration: TimeInterval = 0.21
    ) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
    
    private func handleNavigationAction(
        _ action: NavigationAction
    ) {
        switch action {
        case .back:
            browserViewController.goBack()
        case .forward:
            browserViewController.goForward()
        case .addFavourite:
            break
        case .removeFavourite:
            break
        case .share:
            guard let url = browserViewController.url
            else {
                break
            }
            
            hui_present(
                UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil
                ),
                animated: true
            )
        case .reload:
            browserViewController.reload()
        }
    }
}

extension Safari3ViewController: Safari3BrowserViewControllerDelegate {
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeURL url: URL?
    ) {
        navigationView?.setActiveURL(url)
        
        guard currentViewController == viewController
        else {
            return
        }
        
        showBrowserElseWelcome(
            animated: true
        )
    }
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        titleDidChange title: String?
    ) {
        navigationView?.title = title
    }
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeLoading loading: Bool
    ) {
        navigationView?.setLoading(loading)
    }
}

extension Safari3ViewController: AccountStackBrowserNavigationViewDelegate {
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didStartEditing textField: UITextField
    ) {
        show(
            bookmarksViewController,
            animated: true
        )
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didChangeValue textField: UITextField
    ) {
        
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didEndEditing textField: UITextField
    ) {
        guard let text = textField.text,
              !text.isEmpty
        else {
            browserViewController.url = nil
            show(
                welcomeViewController,
                animated: true
            )
            
            return
        }
        
        let _url: URL?
        if let url = text.url {
            _url = url
        } else if let url = URL.searchURL(withQuery: text) {
            _url = url
        } else {
            _url = nil
        }
        
        navigationView?.setActiveURL(_url)
        browserViewController.url = _url
        
        showBrowserElseWelcome(
            animated: true
        )
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didClickActionsButton button: UIButton
    ) {
        let action = { [weak self] (_ action: NavigationAction) -> UIAction in
            UIAction(
                title: action.title,
                image: UIImage(systemName: action.systemImageName),
                handler: { [weak self] _ in
                    self?.handleNavigationAction(action)
                }
            )
        }
        
        var children: [UIAction] = []
        
        if browserViewController.canGoBack {
            children.append(action(.back))
        }
        
        if browserViewController.canGoForward {
            children.append(action(.forward))
        }
        
        if let _ = browserViewController.url {
            children.append(action(.reload))
        }
        
        children.append(action(.share))
        children.append(action(.addFavourite))
        
        button.sui_presentMenuIfPossible(
            UIMenu(
                children: children
            )
        )
    }
}

extension Safari3ViewController.NavigationAction {
    
    var title: String {
        switch self {
        case .back:
            return "Safari3NavigationActionBack".asLocalizedKey
        case .forward:
            return "Safari3NavigationActionForward".asLocalizedKey
        case .addFavourite:
            return "Safari3NavigationActionAddFavoirite".asLocalizedKey
        case .removeFavourite:
            return "Safari3NavigationActionRemoveFavoirite".asLocalizedKey
        case .share:
            return "Safari3NavigationActionShare".asLocalizedKey
        case .reload:
            return "Safari3NavigationActionReload".asLocalizedKey
        }
    }
    
    var systemImageName: String {
        switch self {
        case .back:
            return "chevron.backward"
        case .forward:
            return "chevron.forward"
        case .addFavourite:
            return "star"
        case .removeFavourite:
            return "star.fill"
        case .share:
            return "square.and.arrow.up"
        case .reload:
            return "arrow.clockwise"
        }
    }
}
