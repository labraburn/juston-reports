//
//  TopupNavigationController.swift
//  iOS
//
//  Created by Anton Spivak on 19.07.2022.
//

import UIKit
import HuetonCORE
import SystemUI

class TopupNavigationController: NavigationController {
    
    let initialConfiguration: InitialConfiguration
    
    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        
        let viewController = TopupAgreementsViewController()
        super.init(rootViewController: viewController)
        
        viewController.delegate = self
        isNavigationBarHidden = true
        interactivePopGestureRecognizer?.isEnabled = false
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func finish(
        with error: Error?
    ) {
        guard !(error is CancellationError)
        else {
            complete()
            return
        }
        
        let viewController = TopupFinishViewController(error: error)
        viewController.delegate = self
        pushViewController(viewController, animated: true)
    }
    
    private func complete() {
        hide(animated: true, popIfAvailable: false)
    }
    
    private func resolveCurrentSheetHeight(
        with containerView: UIView,
        availableCoordinateSpace frame: CGRect
    ) -> CGFloat {
        guard let viewController = topViewController as? PreferredContentSizeHeightViewController
        else {
            return frame.height
        }
        
        var containerViewBounds = frame
        containerViewBounds.origin = .zero
        
        viewController.loadViewIfNeeded()
        viewController.view.layoutIfNeeded()
        
        var preferredContentSizeHeight = viewController.preferredContentSizeHeight(
            with: containerViewBounds
        )
        
        if viewController.view.safeAreaInsets.bottom == 0 {
            preferredContentSizeHeight += containerView.safeAreaInsets.bottom
        }
        
        return preferredContentSizeHeight
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if modalPresentationStyle == .custom, let presentationController = presentationController as? SUISheetPresentationController {
            presentationController.performAnimatedChanges({
                super.pushViewController(viewController, animated: animated)
                presentationController.invalidateDetents()
            })
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        var viewController: UIViewController?
        if let presentationController = presentationController as? SUISheetPresentationController {
            presentationController.performAnimatedChanges({
                viewController = super.popViewController(animated: animated)
            })
        } else {
            viewController = super.popViewController(animated: animated)
        }
        return viewController
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        var viewControllers: [UIViewController]?
        if let presentationController = presentationController as? SUISheetPresentationController {
            presentationController.performAnimatedChanges({
                viewControllers = super.popToViewController(viewController, animated: animated)
            })
        } else {
            viewControllers = super.popToViewController(viewController, animated: animated)
        }
        return viewControllers
    }
    
    override func trickyAnimatedTransitioning(
        for operation: UINavigationController.Operation
    ) -> SUINavigationControllerAnimatedTransitioning? {
        nil
    }
}

extension TopupNavigationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = SUISheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.detents = [
            .init(
                identifier: .init("dynamic"),
                resolutionBlock: { [weak self] view, frame in
                    self?.resolveCurrentSheetHeight(
                        with: view,
                        availableCoordinateSpace: frame
                    ) ?? frame.height
                }
            )
        ]
        return presentationController
    }
}

extension TopupNavigationController: TopupAgreementsViewControllerDelegate {
    
    func topupAgreementsViewController(
        _ viewController: TopupAgreementsViewController,
        didAcceptAgreementsWithError error: Error?
    ) {
        guard let error = error
        else {
            let viewController = TopupProviderViewController(
                address: initialConfiguration.account.convienceSelectedAddress.description
            )
            
            viewController.delegate = self
            pushViewController(viewController, animated: true)
            return
        }
        
        finish(with: error)
    }
}

extension TopupNavigationController: TopupProviderViewControllerDelegate {
    
    func topupProviderViewController(
        _ viewController: TopupProviderViewController,
        didFinishWithError error: Error?
    ) {
        finish(with: error)
    }
}

extension TopupNavigationController: TopupFinishViewControllerDelegate {
    
    func topupFinishViewControllerDidClose(
        _ viewController: TopupFinishViewController
    ) {
        complete()
    }
}
