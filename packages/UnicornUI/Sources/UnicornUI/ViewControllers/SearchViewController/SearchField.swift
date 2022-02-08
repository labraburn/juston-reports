//
//  Created by Anton Spivak
//

import DeclarativeUI
import UIKit

public protocol SearchFieldDelegate: AnyObject {
    func searchField(_ searchField: SearchField, cancelButtonDidClick sender: UIButton)
    func searchField(_ searchField: SearchField, textFieldDidChange textField: UITextField)
}

public final class SearchField: UIView {
    public weak var searchViewController: SearchViewController?
    public weak var delegate: SearchFieldDelegate?

    private let searchImageView = UIImageView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset.Image.search24
        $0.tintColor = Asset.Color.textSecondary
    }

    private let textField = SearchTextField(frame: .zero).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.textColor = Asset.Color.inputText
        $0.borderStyle = .none
        $0.textColor = Asset.Color.inputText
        $0.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }

    private let resetButton = UIButton(type: .custom).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset.Image.cancel16, for: .normal)
        $0.alpha = 0
        $0.addTarget(
            self,
            action: #selector(resetButtonDidClick(_:)),
            for: .touchUpInside
        )
    }

    private let substrateView = UIView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Asset.Color.inputFieldBackground
        $0.layer.cornerRadius = Asset.Size.cornerRadiusSmall
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
    }

    private let cancelButton = UIButton(type: .system).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = Asset.Color.tint
        $0.setTitle(UIKitLocalizedString(for: "Cancel"), for: .normal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.addTarget(
            self,
            action: #selector(cancelButtonDidClick(_:)),
            for: .touchUpInside
        )
    }

    public var text: String? { textField.text }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(substrateView)
        addSubview(cancelButton)

        substrateView.addSubview(searchImageView)
        substrateView.addSubview(textField)
        substrateView.addSubview(resetButton)

        updateBorderColor()

        NSLayoutConstraint.activate {
            searchImageView.leftAnchor.pin(
                to: substrateView.leftAnchor,
                constant: Asset.Size.padding,
                priority: .required
            )
            searchImageView.widthAnchor.pin(to: 24)
            searchImageView.heightAnchor.pin(to: 24)
            searchImageView.centerYAnchor.pin(to: substrateView.centerYAnchor)

            textField.leftAnchor.pin(
                to: searchImageView.rightAnchor,
                constant: Asset.Size.padding
            )
            textField.pin(vertically: substrateView)

            resetButton.leftAnchor.pin(
                to: textField.rightAnchor,
                constant: Asset.Size.padding
            )
            resetButton.widthAnchor.pin(to: 34)
            resetButton.pin(vertically: substrateView)

            substrateView.rightAnchor.pin(to: resetButton.rightAnchor)
            substrateView.pin(vertically: self)
            substrateView.pin(horizontally: self, but: .right)

            cancelButton.pin(vertically: self)
            cancelButton.heightAnchor.pin(to: 36)
            cancelButton.pin(horizontally: self, but: .left)
            cancelButton.leftAnchor.pin(
                to: substrateView.rightAnchor,
                constant: Asset.Size.paddingNormal
            )
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func triggerTextFieldDidChange() {
        textFieldDidChange(textField)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    // MARK: Private

    private func updateBorderColor() {
        substrateView.layer.borderColor = Asset.Color.inputFieldBorder.cgColor
    }

    // MARK: Actions

    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        textField.text = nil
        delegate?.searchField(self, cancelButtonDidClick: sender)
    }

    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        let text = sender.text ?? ""
        UIView.animate(
            withDuration: 0.21,
            animations: {
                self.resetButton.alpha = text.isEmpty ? 0 : 1
            },
            completion: nil
        )
        delegate?.searchField(self, textFieldDidChange: sender)
    }

    @objc
    private func resetButtonDidClick(_ sender: UIButton) {
        textField.text = nil
        textFieldDidChange(textField)
    }
}
