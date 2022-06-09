//
//  Created by Anton Spivak
//

import UIKit

internal class SafariViewNavigationView: UIView {
    
    private let backgroundView = BarBackgroundView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let stackView = UIStackView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    private var overlayLoadingView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.cornerCurve = .continuous
    })
    
    private var views: [(SafariViewController.NavigationItem, UIView)] = [] {
        didSet {
            stackView.arrangedSubviews.forEach({
                $0.removeFromSuperview()
            })
            
            views.forEach({
                stackView.addArrangedSubview($0.1)
            })
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            stackView.arrangedSubviews.forEach({
                $0.tintColor = tintColor
            })
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                overlayLoadingView.startLoadingAnimation(fade: false)
            } else {
                overlayLoadingView.stopLoadingAnimation()
            }
            overlayLoadingView.isUserInteractionEnabled = false
        }
    }

    var items: [SafariViewController.NavigationItem] = [] {
        didSet {
            guard items.count == Set(items).count
            else {
                fatalError("Navigation items at SafariViewController must be unique.")
            }
            
            var views: [(SafariViewController.NavigationItem, UIView)] = []
            items.forEach({
                let view: UIView
                switch $0 {
                case .url:
                    let label = UILabel()
                    label.textColor = .hui_textPrimary
                    label.font = .font(for: .headline)
                    label.textAlignment = .center
                    label.setContentCompressionResistancePriority(.required, for: .horizontal)
                    label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
                    view = label
                }
                views.append(($0, view))
            })
            self.views = views
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(backgroundView)
        addSubview(stackView)
        addSubview(overlayLoadingView)

        NSLayoutConstraint.activate({
            backgroundView.pin(edges: self)

            stackView.topAnchor.pin(to: safeAreaLayoutGuide.topAnchor, constant: 8)
            stackView.heightAnchor.pin(to: 36)
            stackView.pin(horizontally: self, left: 16, right: 16)
            bottomAnchor.pin(to: stackView.bottomAnchor, constant: 6)
            
            overlayLoadingView.topAnchor.pin(to: safeAreaLayoutGuide.topAnchor, constant: 8)
            overlayLoadingView.pin(horizontally: self, left: 6, right: 6)
            bottomAnchor.pin(to: overlayLoadingView.bottomAnchor, constant: 6)
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view(
        for item: SafariViewController.NavigationItem
    ) -> UIView? {
        views.filter({ $0.0 == item }).first?.1
    }
}
