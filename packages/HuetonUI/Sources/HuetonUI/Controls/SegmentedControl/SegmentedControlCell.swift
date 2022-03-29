//
//  SegmentedControlCell.swift
//
//
//  Created by Anton Spivak on 28.01.2022.
//

import UIKit

internal class SegmentedControlCell: UICollectionViewCell {
    private let textLabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private var item: SegmentedControl.Item?

    var normalStyle: SegmentedControl.Style = .defaultNormal
    var selectedStyle: SegmentedControl.Style = .defaultSelected

    var isUserSelected = false {
        didSet {
            updateCurrentStyle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        NSLayoutConstraint.activate {
            textLabel.pin(
                edges: self,
                insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            )
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fill(with item: SegmentedControl.Item) {
        self.item = item
        switch item {
        case let .text(text):
            textLabel.text = text
        }

        updateCurrentStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerCurve = .continuous
        layer.cornerRadius = bounds.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCurrentStyle()
    }

    func updateCurrentStyle() {
        if isUserSelected {
            use(style: selectedStyle)
        }
        else {
            use(style: normalStyle)
        }
    }

    // MARK: Private

    private func use(style: SegmentedControl.Style) {
        backgroundColor = style.backgroundColor
        textLabel.textColor = style.foregroundColor

        if let borderColor = style.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        }
        else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
}
