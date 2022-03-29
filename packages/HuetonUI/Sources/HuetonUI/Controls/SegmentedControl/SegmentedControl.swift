//
//  SegmentedControl.swift
//
//
//  Created by Anton Spivak on 28.01.2022.
//

import UIKit
import DeclarativeUI

open class SegmentedControl: UIControl {
    
    public enum Item {
        case text(value: String)
    }

    public struct Style {
        let backgroundColor: UIColor
        let foregroundColor: UIColor
        let borderColor: UIColor?
    }

    public struct Insets {
        let left: CGFloat
        let right: CGFloat

        public init(left: CGFloat, right: CGFloat) {
            self.left = left
            self.right = right
        }
    }

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var activeConstraints = [NSLayoutConstraint]()

    private let substrateView = UIView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
        $0.backgroundColor = .clear
    }

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .segmented
    ).with {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>?

    override open var clipsToBounds: Bool {
        get {
            super.clipsToBounds
        }
        set {
            super.clipsToBounds = newValue
            collectionView.clipsToBounds = newValue
        }
    }

    open var selectedItem: Item? {
        didSet {
            guard selectedItem != oldValue
            else {
                return
            }

            var reloadItems: [Item] = []
            if let oldValue = oldValue {
                reloadItems.append(oldValue)
            }

            if let selectedItem = selectedItem {
                reloadItems.append(selectedItem)
            }

            guard var snapshot = dataSource?.snapshot()
            else {
                collectionView.reloadData()
                return
            }

            snapshot.reloadItems(reloadItems)
            dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }

    open var selectedIndex: Int? {
        guard let selectedItem = selectedItem
        else {
            return nil
        }

        return items.firstIndex(of: selectedItem)
    }

    open var items: [Item] = [] {
        didSet {
            guard self.items != oldValue
            else {
                return
            }

            _updateItems(items, animated: false)
        }
    }

    open var insets: Insets = .init(left: 0, right: 0) {
        didSet {
            collectionView.contentInset = insets.uiEdgeInsets
        }
    }

    open var normalStyle: Style = .defaultNormal {
        didSet {
            collectionView.reloadData()
        }
    }

    open var selectedStyle: Style = .defaultSelected {
        didSet {
            collectionView.reloadData()
        }
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        addSubview(substrateView)
        substrateView.addSubview(collectionView)

        collectionView.register(SegmentedControlCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self

        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                guard let self = self
                else {
                    return nil
                }

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath
                ) as? SegmentedControlCell

                cell?.isUserSelected = self.selectedItem == item
                cell?.normalStyle = self.normalStyle
                cell?.selectedStyle = self.selectedStyle
                cell?.fill(with: item)

                return cell
            }
        )
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func updateConstraints() {
        super.updateConstraints()

        activeConstraints.forEach { $0.isActive = false }
        activeConstraints = NSLayoutConstraint.activate {
            substrateView.topAnchor.pin(to: topAnchor)
            substrateView.pin(horizontally: self)
            collectionView.pin(edges: substrateView)
        }
    }

    public func scrollToSelectedItemAnimated(_ animated: Bool) {
        guard let index = selectedIndex
        else {
            return
        }

        let _animated = window != nil && animated
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: _animated
        )
    }

    private func _updateItems(_ items: [Item], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: API

    open func updateItems(_ items: [Item], animated: Bool = false) {
        guard self.items != items
        else {
            return
        }

        _updateItems(items, animated: animated)
    }
}

extension SegmentedControl: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        feedbackGenerator.prepare()
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextSelectedItem = dataSource?.itemIdentifier(for: indexPath)
        let shouldSendActions = nextSelectedItem != selectedItem

        selectedItem = nextSelectedItem

        if shouldSendActions {
            scrollToSelectedItemAnimated(true)
            feedbackGenerator.selectionChanged()

            sendActions(for: .valueChanged)
        }
    }
}

extension SegmentedControl.Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value):
            hasher.combine(value)
        }
    }
}

extension SegmentedControl.Style {
    static let defaultNormal = SegmentedControl.Style(
        backgroundColor: .clear,
        foregroundColor: .hui_textPrimary,
        borderColor: .hui_textSecondary
    )

    static let defaultSelected = SegmentedControl.Style(
        backgroundColor: .hui_tint,
        foregroundColor: .white,
        borderColor: nil
    )
}

private extension SegmentedControl.Insets {
    var uiEdgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
}

private extension UICollectionViewLayout {
    static var segmented: UICollectionViewLayout {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .estimated(48),
                    heightDimension: .fractionalHeight(1)
                )
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .estimated(48),
                    heightDimension: .fractionalHeight(1)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 6
            return section
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: provider,
            configuration: configuration
        )

        return layout
    }
}
