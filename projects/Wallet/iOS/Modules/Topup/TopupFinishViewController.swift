//
//  TopupFinishViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.07.2022.
//

import UIKit
import JustonUI
import EasyConfetti

protocol TopupFinishViewControllerDelegate: AnyObject {
    
    func topupFinishViewControllerDidClose(
        _ viewController: TopupFinishViewController
    )
}

class TopupFinishViewController: UIViewController {

    weak var delegate: TopupFinishViewControllerDelegate?
    
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
        $0.text = "VeneraExchangeFinishDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private lazy var doneButton = PrimaryButton(title: "CommonClose".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var confettiView = ConfettiView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        $0.config.customize = { cells in
            cells.forEach({
                $0.birthRate = 10
                $0.emissionRange = CGFloat.pi * 0.8
            })
        }
        $0.config.colors = [
            .jus_letter_red,
            .jus_letter_yellow,
            .jus_letter_blue,
            .jus_letter_green,
            .jus_letter_violet,
            .jus_letter_purple,
        ]
    })
    
    let error: Error?
    
    // Currently we can't handle error
    // TODO: Handle error
    init(error: Error?) {
        self.error = error
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .jus_backgroundPrimary
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(desriptionLabel)
        view.addSubview(doneButton)
        view.addSubview(confettiView)
        
        NSLayoutConstraint.activate({
            titleLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 12)
            titleLabel.pin(horizontally: view, left: 16, right: 16)
            
            imageView.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 8)
            imageView.centerXAnchor.pin(to: view.centerXAnchor)
//            imageView.widthAnchor.pin(to: imageView.heightAnchor)
            
            desriptionLabel.topAnchor.pin(to: imageView.bottomAnchor, constant: 8)
            desriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(to: desriptionLabel.bottomAnchor, constant: 24)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: doneButton.bottomAnchor, constant: 8)
            
            confettiView.pin(edges: view)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Not possible right now, but
        guard error == nil
        else {
            return
        }
        
        confettiView.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.42, execute: { [weak self] in
            self?.confettiView.stop()
        })
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        delegate?.topupFinishViewControllerDidClose(self)
    }
}

extension TopupFinishViewController: PreferredContentSizeHeightViewController {
    
    func preferredContentSizeHeight(
        with containerFrame: CGRect
    ) -> CGFloat {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: containerFrame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return size.height
    }
}
