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
import CoreData

class Safari3ViewController: UIViewController {
    
    enum NavigationAction {
        
        case back
        case forward
        case addFavourite(url: URL, title: String)
        case removeFavourite(id: NSManagedObjectID)
        case share
        case reload
        case explore
        case search
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
            welcomeViewController.account = account
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeViewController.delegate = self
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
        case .search:
            let _ = navigationView?.becomeFirstResponder()
        case let .addFavourite(url, title):
            guard let accountID = account?.objectID
            else {
                break
            }

            Task { @PersistenceWritableActor in
                let account = PersistenceAccount.writeableObject(id: accountID)
                let object = PersistenceBrowserFavourite(
                    title: title,
                    subtitle: nil,
                    url: url,
                    account: account
                )
                
                try? object.save()
            }
        case .explore:
            navigationView?.setActiveURL(nil)
            browserViewController.url = nil
            
            show(
                welcomeViewController,
                animated: true
            )
        case let .removeFavourite(id):
            Task { @PersistenceWritableActor in
                let object = PersistenceBrowserFavourite.writeableObject(id: id)
                try? object.delete()
            }
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

extension Safari3ViewController: Safari3WelcomeViewControllerDelegate {
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickFavouritesEmptyView view: Safari3WelcomePlaceholderCollectionReusableView
    ) {
        let _ = navigationView?.becomeFirstResponder()
    }
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickBrowserFavourite favourite: PersistenceBrowserFavourite
    ) {
        _open(favourite.url)
    }
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickBrowserBanner banner: PersistenceBrowserBanner
    ) {
        switch banner.action {
        case .unknown:
            break
        case let .inapp(value):
            guard let account = account,
                  let viewController = value.viewController(viewer: account)
            else {
                break
            }
            topmostPresentedViewController.hui_present(viewController, animated: true)
        case let .url(value):
            _open(value)
        }
    }
    
    private func _open(_ url: URL) {
        navigationView?.setActiveURL(url)
        browserViewController.url = url
        
        showBrowserElseWelcome(
            animated: true
        )
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
        
        switch currentViewController {
        case browserViewController:
            if browserViewController.canGoBack {
                children.append(action(.back))
            }
            
            if browserViewController.canGoForward {
                children.append(action(.forward))
            }
            
            if let _ = browserViewController.url {
                children.append(action(.reload))
                children.append(action(.share))
            }
            
            if let url = browserViewController.url,
               let favouriteURL = url.favouriteURL
            {
                let fetchRequest = PersistenceBrowserFavourite.fetchRequest(url: favouriteURL)
                let result = (try? PersistenceBrowserFavourite.readableExecute(fetchRequest)) ?? []
                
                if let first = result.first {
                    children.append(action(.removeFavourite(id: first.objectID)))
                } else {
                    children.append(
                        action(
                            .addFavourite(
                                url: favouriteURL,
                                title: browserViewController.title ?? favouriteURL.absoluteString
                            )
                        )
                    )
                }
            }
            
            children.append(action(.explore))
        case welcomeViewController:
            children.append(action(.search))
        default:
            break
        }
        
        guard !children.isEmpty
        else {
            return
        }
        
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
        case .explore:
            return "Safari3NavigationActionExplore".asLocalizedKey
        case .search:
            return "Safari3NavigationActionSearch".asLocalizedKey
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
        case .explore:
            return "escape"
        case .search:
            return "magnifyingglass"
        }
    }
}

private extension URL {
    
    var favouriteURL: URL? {
        guard let host = host,
              let scheme = scheme
        else {
            return nil
        }
        return URL(string: "\(scheme)://\(host)")
    }
}
