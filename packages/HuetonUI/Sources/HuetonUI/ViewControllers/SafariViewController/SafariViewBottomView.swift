//
//  Created by Anton Spivak
//

import UIKit

internal protocol SafariViewBottomViewDelegate: AnyObject {
    
    func safariViewBottomView(
        _ view: SafariViewBottomView,
        didSelectItem item: SafariViewController.BottomItem
    )
}

internal class SafariViewBottomView: UIView {
    
    private let backgroundView = BarBackgroundView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private let stackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    })
    
    private var views: [(SafariViewController.BottomItem, UIView)] = [] {
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

    weak var delegate: SafariViewBottomViewDelegate?

    var items: [SafariViewController.BottomItem] = [] {
        didSet {
            guard items.count == Set(items).count
            else {
                fatalError("Navigation items at SafariViewController must be unique.")
            }
            
            var views: [(SafariViewController.BottomItem, UIView)] = []
            items.forEach({
                let button = UIButton(type: .custom)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.insertHighlightingScaleAnimation()
                button.insertFeedbackGenerator(style: .soft)
                button.setImage($0.image, for: .normal)
                button.addTarget(self, action: #selector(didSelectButton(_:)), for: .touchUpInside)
                views.append(($0, button))
            })
            self.views = views
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(backgroundView)
        addSubview(stackView)

        NSLayoutConstraint.activate({
            backgroundView.pin(edges: self)

            stackView.topAnchor.pin(to: topAnchor, constant: 2)
            stackView.heightAnchor.pin(to: 49)
            stackView.pin(horizontally: self)
            safeAreaLayoutGuide.bottomAnchor.pin(to: stackView.bottomAnchor)
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func view(
        for item: SafariViewController.BottomItem
    ) -> UIView? {
        views.filter({ $0.0 == item }).first?.1
    }

    // MARK: Actions

    @objc
    func didSelectButton(_ sender: UIButton) {
        guard let index = stackView.arrangedSubviews.firstIndex(of: sender)
        else {
            return
        }

        delegate?.safariViewBottomView(self, didSelectItem: items[index])
    }
}

private extension SafariViewController.BottomItem {
    
    var image: UIImage? {
        let systemName: String
        switch self {
        case .back:
            systemName = "chevron.backward"
        case .forward:
            systemName = "chevron.forward"
        case .share:
            systemName = "square.and.arrow.up"
        case .safari:
            systemName = "safari"
        }
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20)
        return UIImage(
            systemName: systemName,
            withConfiguration: configuration
        )
    }
}
