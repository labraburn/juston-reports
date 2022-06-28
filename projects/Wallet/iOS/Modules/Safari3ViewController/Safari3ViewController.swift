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
        case backToBroser
        case search
    }
    
    enum PresentationState {
        
        case welcome
        case search(query: String?)
        case browsing(url: URL, title: String?)
        
        var isBrowsing: Bool {
            switch self {
            case .browsing:
                return true
            default:
                return false
            }
        }
    }
    
    override var childForStatusBarStyle: UIViewController? { currentViewController }
    override var childForHomeIndicatorAutoHidden: UIViewController? { currentViewController }
    override var childForStatusBarHidden: UIViewController? { currentViewController }
    override var childViewControllerForPointerLock: UIViewController? { currentViewController }
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? { currentViewController }
    
    private let browserViewController = Safari3BrowserViewController()
    private let searchViewController = Safari3SearchViewController()
    private let welcomeViewController = Safari3WelcomeViewController()
    
    private var presentationStates: [PresentationState] = []
    private var currentViewController: UIViewController? {
        children.first
    }
    
    private weak var navigationView: AccountStackBrowserNavigationView?
    
    var account: PersistenceAccount? = nil {
        didSet {
            searchViewController.account = account
            welcomeViewController.account = account
            browserViewController.account = account
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeViewController.delegate = self
        browserViewController.delegate = self
        searchViewController.delegate = self
        
        push(
            presentationState: .welcome,
            animated: false
        )
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    func attach(_ view: AccountStackBrowserNavigationView) {
        navigationView = view
        navigationView?.delegate = self
//        navigationView?.setActiveURL(nil)
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
            exchangeLastPresentationState(
                toPresentationState: .search(query: nil),
                animated: true
            )
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
            switch presentationStates.last {
            case .welcome:
                break
            default:
                push(
                    presentationState: .welcome,
                    animated: true
                )
            }
        case .backToBroser:
            popPresentationState(
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

extension Safari3ViewController {
    
    private func push(
        presentationState: PresentationState,
        animated: Bool
    ) {
        presentationStates.append(presentationState)
        __show(
            presentationState: presentationState,
            animated: animated
        )
    }
    
    private func exchangeLastPresentationState(
        toPresentationState: PresentationState,
        animated: Bool
    ) {
        let _ = presentationStates.popLast()
        push(
            presentationState: toPresentationState,
            animated: animated
        )
    }
    
    private func popPresentationState(
        animated: Bool
    ) {
        guard let _ = presentationStates.popLast(),
              let previous = presentationStates.last
        else {
            push(
                presentationState: .welcome,
                animated: animated
            )
            
            return
        }
        
        __show(
            presentationState: previous,
            animated: animated
        )
    }
    
    private func __show(
        presentationState: PresentationState,
        animated: Bool
    ) {
        switch presentationState {
        case .welcome:
            searchViewController.query = nil
            
//            Not called, for better UX
//            browserViewController.url = nil
            
            __show(welcomeViewController, animated: animated)
            
            navigationView?.resignFirstResponder()
            navigationView?.text = nil
            navigationView?.title = nil
            navigationView?.setLoading(false)
        case let .browsing(url, title):
            searchViewController.query = nil
            browserViewController.url = url
            
            __show(browserViewController, animated: animated)
            
            navigationView?.resignFirstResponder()
            navigationView?.text = url.absoluteString
            navigationView?.title = title ?? url.host
        case let .search(query):
            searchViewController.query = query
            
//            Not called, for better UX
//            browserViewController.url = nil
            
            __show(searchViewController, animated: animated)
            
            navigationView?.becomeFirstResponder()
            navigationView?.setLoading(false)
            
//            Not called, for better UX
//            navigationView?.text = nil
//            navigationView?.title = nil
        }
    }
    
    private func __show(
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
            
            self.__updateAppearance(animated: false)
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
    
    private func __updateAppearance(
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
}

extension Safari3ViewController: Safari3WelcomeViewControllerDelegate {
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickFavouritesEmptyView view: Safari3WelcomePlaceholderCollectionReusableView
    ) {
        push(
            presentationState: .search(query: nil),
            animated: true
        )
    }
    
    func safari3WelcomeViewController(
        _ viewController: Safari3WelcomeViewController,
        didClickBrowserFavourite favourite: PersistenceBrowserFavourite
    ) {
        exchangeLastPresentationState(
            toPresentationState: .browsing(
                url: favourite.url,
                title: favourite.title
            ),
            animated: true
        )
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
            exchangeLastPresentationState(
                toPresentationState: .browsing(
                    url: value,
                    title: nil
                ),
                animated: true
            )
        }
    }
}

extension Safari3ViewController: Safari3SearchViewControllerDelegate {
    
    func safari3SearchViewController(
        _ viewController: Safari3SearchViewController,
        didSelectBrowserFavourite favourite: PersistenceBrowserFavourite
    ) {
        exchangeLastPresentationState(
            toPresentationState: .browsing(
                url: favourite.url,
                title: favourite.title
            ),
            animated: true
        )
    }
}

extension Safari3ViewController: Safari3BrowserViewControllerDelegate {
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeURL url: URL?
    ) {
        let nextPresentationState: PresentationState
        if let url = url {
            nextPresentationState = .browsing(
                url: url,
                title: nil
            )
        } else {
            nextPresentationState = .welcome
        }
        
        exchangeLastPresentationState(
            toPresentationState: nextPresentationState,
            animated: true
        )
    }
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        titleDidChange title: String?
    ) {
        switch presentationStates.last {
        case .browsing:
            navigationView?.title = title
        default:
            break
        }
    }
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeLoading loading: Bool
    ) {
        switch presentationStates.last {
        case .browsing:
            navigationView?.setLoading(loading)
        default:
            navigationView?.setLoading(false)
        }
    }
    
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        wantsHomeWhileError error: Error?
    ) {
        exchangeLastPresentationState(
            toPresentationState: .welcome,
            animated: true
        )
    }
}

extension Safari3ViewController: AccountStackBrowserNavigationViewDelegate {
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didStartEditing textField: UITextField
    ) {
        switch presentationStates.last {
        case .search:
            navigationView(
                view,
                didChangeValue: textField
            )
        default:
            push(
                presentationState: .search(query: textField.text),
                animated: true
            )
        }
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didChangeValue textField: UITextField
    ) {
        exchangeLastPresentationState(
            toPresentationState: .search(query: textField.text),
            animated: true
        )
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didEndEditing textField: UITextField
    ) {
        switch presentationStates.last {
        case .search:
            popPresentationState(
                animated: true
            )
        default:
            break
        }
    }
    
    func navigationView(
        _ view: AccountStackBrowserNavigationView,
        didClickGo textField: UITextField
    ) {
        guard let text = textField.text,
              !text.isEmpty
        else {
            switch presentationStates.last {
            case .search:
                popPresentationState(
                    animated: true
                )
            default:
                break
            }
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
        
        let nextPresentationState: PresentationState
        if let _url = _url {
            nextPresentationState = .browsing(
                url: _url,
                title: nil
            )
        } else {
            nextPresentationState = .welcome
        }
        
        exchangeLastPresentationState(
            toPresentationState: nextPresentationState,
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
        
        switch presentationStates.last {
        case .none:
            break
        case .welcome:
            children.append(action(.search))
            let count = presentationStates.count
            if count > 1, presentationStates[count - 2].isBrowsing {
                children.append(action(.backToBroser))
            }
        case let .browsing(url, _):
            if browserViewController.canGoBack {
                children.append(action(.back))
            }

            if browserViewController.canGoForward {
                children.append(action(.forward))
            }
            
            children.append(action(.reload))
            children.append(action(.share))
            
            if let favouriteURL = url.favouriteURL {
                let fetchRequest = PersistenceBrowserFavourite.fetchRequest(url: favouriteURL)
                let result = (try? PersistenceBrowserFavourite.readableExecute(fetchRequest)) ?? []

                if let first = result.first {
                    children.append(
                        action(
                            .removeFavourite(
                                id: first.objectID
                            )
                        )
                    )
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
        case .search:
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
        case .backToBroser:
            return "Safari3NavigationActionBackToBrowser".asLocalizedKey
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
        case .backToBroser:
            return "escape"
        case .search:
            return "magnifyingglass"
        }
    }
}

private extension URL {
    
    var favouriteURL: URL? {
        guard var host = host,
              let scheme = scheme
        else {
            return nil
        }
        
        if host.hasSuffix("/") {
            let _ = host.removeLast()
        }
        
        return URL(string: "\(scheme)://\(host)")
    }
}
