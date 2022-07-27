//
//  ConfirmationViewController.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import UIKit
import JustonCORE
import JustonUI

class ConfirmationViewController: UIViewController {
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .title3)
        $0.textColor = .jus_textPrimary
        $0.text = "VeneraExchangeFinishTitle".asLocalizedKey
        $0.numberOfLines = 1
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = .jus_veneraJuston128
        $0.contentMode = .center
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    })
    
    private let desriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .body)
        $0.textColor = .jus_textPrimary
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private lazy var doneButton = PrimaryButton(title: "UserConfirmationConfirmButton".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "UserConfirmationDenyButton".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })
    
    let image: AlertViewControllerImage
    let message: String
    let completion: (_ confirmed: Bool) -> ()
    
    init(
        image: AlertViewControllerImage,
        message: String,
        completion: @escaping (_ confirmed: Bool) -> ()
    ) {
        self.image = image
        self.message = message
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = "UserConfirmationTitle".asLocalizedKey
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = title
        imageView.image = image.image
        desriptionLabel.text = message
        
        view.backgroundColor = .jus_backgroundPrimary
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(desriptionLabel)
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate({
            titleLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 18)
            titleLabel.pin(horizontally: view, left: 16, right: 16)
            
            imageView.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 8)
            imageView.centerXAnchor.pin(to: view.centerXAnchor)
            
            desriptionLabel.topAnchor.pin(to: imageView.bottomAnchor, constant: 8)
            desriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(to: desriptionLabel.bottomAnchor, constant: 12)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: doneButton.bottomAnchor, constant: 8)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })
    }
    
    private func resolveCurrentSheetHeight(
        with containerView: UIView,
        availableCoordinateSpace frame: CGRect
    ) -> CGFloat {
        view.layoutIfNeeded()
        var preferredContentSizeHeight = view.systemLayoutSizeFitting(
            CGSize(width: frame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height
        
        if view.safeAreaInsets.bottom == 0 {
            preferredContentSizeHeight += containerView.safeAreaInsets.bottom
        }
        
        return preferredContentSizeHeight
    }
    
    @objc
    private func doneButtonDidClick(_ sender: JustonButton) {
        hide(animated: true, completion: {
            self.completion(true)
        })
    }
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        hide(animated: true, completion: {
            self.completion(false)
        })
    }
}

extension ConfirmationViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let detent = SUISheetPresentationControllerDetent(
            identifier: .init("dynamic"),
            resolutionBlock: { [weak self] view, frame in
                self?.resolveCurrentSheetHeight(
                    with: view,
                    availableCoordinateSpace: frame
                ) ?? frame.height
            }
        )
        
        let presentationController = SUISheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.detents = [detent]
        presentationController.selectedDetentIdentifier = nil
        return presentationController
    }
}
