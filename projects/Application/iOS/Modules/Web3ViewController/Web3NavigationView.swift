//
//  Web3NavigationView.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

protocol Web3NavigationViewDelegate: AnyObject {
    
    func web3NavigationView(
        _ view: Web3NavigationView,
        didClickCloseButton sender: UIControl
    )
}

class Web3NavigationView: UIView {

    private let backgroundView = Web3NavigationViewBackgroundView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let horiaontalStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    })

    private let progessView = UIProgressView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.pin(to: 2).isActive = true
        $0.progress = 0.4
        $0.trackTintColor = .clear
    })
    
    private let closeButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.pin(to: 44).isActive = true
        $0.heightAnchor.pin(to: 44).isActive = true
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    })
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .headline)
        $0.textAlignment = .center
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required - 1, for: .horizontal)
    })
    
    var isLoading: Bool {
        get { !progessView.isHidden }
        set { progessView.isHidden = !newValue }
    }

    var progress: Float {
        get { progessView.progress }
        set { progessView.progress = newValue }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    weak var delegate: Web3NavigationViewDelegate?
    
    override var tintColor: UIColor! {
        didSet {
            progessView.progressTintColor = tintColor
            horiaontalStackView.arrangedSubviews.forEach {
                $0.tintColor = tintColor
            }
        }
    }
    
    init() {
        super.init(frame: .zero)

        addSubview(backgroundView)
        addSubview(horiaontalStackView)
        addSubview(progessView)
        
        horiaontalStackView.addArrangedSubview(closeButton)
        horiaontalStackView.addArrangedSubview(titleLabel)
        horiaontalStackView.addArrangedSubview({
            let view = UIView()
            view.widthAnchor.pin(to: 44).isActive = true
            view.heightAnchor.pin(to: 44).isActive = true
            return view
        }())
        
        closeButton.addTarget(self, action: #selector(closeButtonDidClick(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate {
            backgroundView.pin(edges: self)

            horiaontalStackView.topAnchor.pin(to: safeAreaLayoutGuide.topAnchor, constant: 4)
            horiaontalStackView.heightAnchor.pin(to: 44)
            horiaontalStackView.pin(horizontally: self, left: 6, right: 6)
            bottomAnchor.pin(to: horiaontalStackView.bottomAnchor, constant: 4)

            progessView.pin(horizontally: self, left: -4, right: -4)
            progessView.heightAnchor.pin(to: 1)
            bottomAnchor.pin(to: progessView.bottomAnchor, constant: 0)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Actions
    
    @objc
    private func closeButtonDidClick(_ sender: UIButton) {
        delegate?.web3NavigationView(self, didClickCloseButton: sender)
    }
}

private class Web3NavigationViewBackgroundView: UIView {
    
    public let tintView = UIView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0.86
    }

    private let visualEffectView = UIVisualEffectView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.effect = UIBlurEffect(style: .regular)
    }

    override public var tintColor: UIColor! {
        get { tintView.backgroundColor ?? .clear }
        set { tintView.backgroundColor = newValue }
    }

    public init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        visualEffectView.backgroundColor = .clear
        tintColor = .hui_backgroundSecondary

        addSubview(tintView)
        addSubview(visualEffectView)

        NSLayoutConstraint.activate {
            tintView.pin(edges: self)
            visualEffectView.pin(edges: self)
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
