//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

public protocol SearchResultsViewController: AnyObject {
    func searchField(_ searchField: SearchField, didChangeQuery query: String)
}

public protocol SearchViewControllerDelegate: AnyObject {
    func searchViewControllerWillDismiss(
        _ viewController: SearchViewController
    )

    func searchViewControllerDidDismiss(
        _ viewController: SearchViewController
    )
}

public final class SearchViewController: UIViewController {
    public let resultsViewController: UIViewController & SearchResultsViewController

    public weak var searchField: SearchField?
    public weak var delegate: SearchViewControllerDelegate?

    internal var searchView: SearchView { view as! SearchView }

    public init(resultsViewController: UIViewController & SearchResultsViewController) {
        self.resultsViewController = resultsViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let view = SearchView()
        self.view = view
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        addChild(resultsViewController)
        searchView.resultsView = resultsViewController.view
        resultsViewController.didMove(toParent: self)

        sui_isContentScrollViewObservable = false
        resultsViewController.sui_isContentScrollViewObservable = false
    }

    // MARK: SystemUI

    override public func sui_shouldApplyUnclampedContentInsets(
        fromParentViewController parentViewController: UIViewController
    ) -> Bool {
        false
    }

    // MARK: Presentation

    public func present(
        with parentViewController: UIViewController,
        in containerView: UIView,
        completion: (() -> Void)?
    ) {
        parentViewController.addChild(self)

        containerView.addSubview(view)
        view.frame = containerView.bounds
        view.alpha = 0

        searchField?.delegate = self
        searchField?.triggerTextFieldDidChange()

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.view.alpha = 1
            },
            completion: { _ in
                self.view.alpha = 1
                self.didMove(toParent: parentViewController)
            }
        )
    }

    public func dismiss(
        completion: (() -> Void)?
    ) {
        willMove(toParent: nil)

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.view.alpha = 0
            },
            completion: { _ in
                self.view.alpha = 0
                self.view.removeFromSuperview()

                self.removeFromParent()
                completion?()
            }
        )
    }
}

extension SearchViewController: SearchFieldDelegate {
    public func searchField(_ searchField: SearchField, cancelButtonDidClick sender: UIButton) {
        delegate?.searchViewControllerWillDismiss(self)
        dismiss {
            self.delegate?.searchViewControllerDidDismiss(self)
        }
    }

    public func searchField(_ searchField: SearchField, textFieldDidChange textField: UITextField) {
        resultsViewController.searchField(searchField, didChangeQuery: textField.text ?? "")
    }
}
