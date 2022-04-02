//
//  DashboardStackCardView.swift
//  iOS
//
//  Created by Anton Spivak on 13.03.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import CoreData

protocol DashboardStackCardViewDelegate: AnyObject {
    
    func cardStackCardView(
        _ view: UIView,
        didClickRemoveButtonWithModel model: DashboardStackView.Model
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickSendButtonWithModel model: DashboardStackView.Model
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickReceiveButtonWithModel model: DashboardStackView.Model
    )
}

final class DashboardStackCardView: UIView {
    
    enum State: Equatable {
        
        case hidden
        case large
        case compact
    }
    
    let model: DashboardStackView.Model
    
    weak var delegate: DashboardStackCardViewDelegate? {
        didSet {
            compactContentView.delegate = delegate
            largeContentView.delegate = delegate
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private(set) var state: State = .large
    
    private lazy var compactContentView = DashboardStackCardCompactContentView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var largeContentView = DashboardStackCardLargeContentView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var backgroundView = DashboardStackCardBackgroundView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    init(model: DashboardStackView.Model) {
        self.model = model
        
        super.init(frame: .zero)
        
        addSubview(backgroundView)
        addSubview(largeContentView)
        addSubview(compactContentView)
        
        NSLayoutConstraint.activate({
            backgroundView.pin(edges: self)
            largeContentView.pin(edges: self)
            compactContentView.pin(edges: self)
        })
        
        _update(state: state, animated: false)
        model.account.changes = { [weak self] in
            self?._reload()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.layer.cornerRadius = cornerRadius
        compactContentView.layer.cornerRadius = cornerRadius
        largeContentView.layer.cornerRadius = cornerRadius
        
        layer.applyFigmaShadow(
            color: UIColor(rgb: 0x232020),
            alpha: 0.12,
            x: 0,
            y: 24,
            blur: 26,
            spread: 0,
            cornerRadius: cornerRadius
        )
    }
    
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        _update(state: state, animated: true, duration: 0.42)
    }
    
    // MARK: API
    
    func update(state: State, animated: Bool) {
        guard self.state != state
        else {
            return
        }
        
        self.state = state
        _update(state: state, animated: animated)
    }
    
    // MARK: Private
    
    private func _reload() {
        compactContentView._reload()
        largeContentView._reload()
        backgroundView._reload()
    }
    
    private func _update(state: State, animated: Bool, duration: TimeInterval? = nil) {
        if backgroundView.superview != self {
            addSubview(backgroundView)
            backgroundView.pinned(edges: self)
        }
        
        if largeContentView.superview != self {
            addSubview(largeContentView)
            largeContentView.pinned(edges: self)
        }
        
        if compactContentView.superview != self {
            addSubview(compactContentView)
            compactContentView.pinned(edges: self)
        }
        
        UIView.performWithoutAnimation({
            backgroundView.overlayView.isHidden = false
            largeContentView.isHidden = false
            compactContentView.isHidden = false
        })
        
        let hiddenOrDimmed = state == .hidden || tintAdjustmentMode == .dimmed
        
        let animations = {
            self.backgroundView.overlayView.alpha = hiddenOrDimmed ? 1 : 0
            self.largeContentView.alpha = state == .large ? 1 : 0
            self.compactContentView.alpha = state == .compact ? 1 : 0
        }
        
        let completion = { (_ finished: Bool) in
            self.backgroundView.overlayView.isHidden = self.backgroundView.overlayView.alpha == 0
            
            self.largeContentView.isHidden = self.largeContentView.alpha == 0
            if self.largeContentView.isHidden {
                self.largeContentView.removeFromSuperview()
            }
            
            self.compactContentView.isHidden = self.compactContentView.alpha == 0
            if self.compactContentView.isHidden {
                self.compactContentView.removeFromSuperview()
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: duration ?? (state != .hidden ? 1.84 : 0.21),
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
}

//
// MARK: DashboardStackCardContentView
//

private class DashboardStackCardContentView: UIView {
    
    let model: DashboardStackView.Model
    
    weak var delegate: DashboardStackCardViewDelegate?
    
    init(model: DashboardStackView.Model) {
        self.model = model
        
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        
        _reload()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    fileprivate func _reload() {
        layer.borderColor = model.style.borderColor.cgColor
    }
    
    fileprivate func more() -> UIMenu {
        UIMenu(children: [
            UIAction(title: "CommonRemove".asLocalizedKey, attributes: .destructive, handler: { [weak self] _ in
                guard let self = self
                else {
                    return
                }
                
                self.removeButtonDidClick(nil)
            })
        ])
    }
    
    // MARK: Actions
    
    @objc
    fileprivate func sendButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(self, didClickSendButtonWithModel: model)
    }
    
    @objc
    fileprivate func receiveButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(self, didClickReceiveButtonWithModel: model)
    }
    
    @objc
    fileprivate func removeButtonDidClick(_ sender: UIControl?) {
        delegate?.cardStackCardView(self, didClickRemoveButtonWithModel: model)
    }
}

//
// MARK: DashboardStackCardCompactContentView
//

private final class DashboardStackCardCompactContentView: DashboardStackCardContentView {
    
    private let accountNameLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let accountCurrentAddressLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.lineBreakMode = .byTruncatingMiddle
        $0.numberOfLines = 1
        $0.textAlignment = .center
    })
    
    private let moreButton = UIButton(type: .system).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.insertHighlightingScaleDownAnimation()
        $0.insertFeedbackGenerator(style: .medium)
        $0.setImage(.hui_more24, for: .normal)
    })
    
    override init(model: DashboardStackView.Model) {
        super.init(model: model)
        
        addSubview(accountNameLabel)
        addSubview(accountCurrentAddressLabel)
        addSubview(moreButton)
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = more()
        
        NSLayoutConstraint.activate({
            accountNameLabel.topAnchor.pin(to: topAnchor, constant: 18)
            accountNameLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountNameLabel.heightAnchor.pin(to: 33)
            
            moreButton.leftAnchor.pin(to: accountNameLabel.rightAnchor, constant: 8)
            moreButton.topAnchor.pin(to: topAnchor, constant: 21)
            rightAnchor.pin(to: moreButton.rightAnchor, constant: 16)
            
            accountCurrentAddressLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountCurrentAddressLabel.heightAnchor.pin(to: 29)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 12)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 20)
        })
        
        _reload()
    }
    
    override func _reload() {
        super._reload()
        
        let name = model.account.name
        let address = Address(rawAddress: model.account.rawAddress)
            .convert(representation: .base64url(flags: [.bounceable]))
        
        accountNameLabel.textColor = model.style.textColorPrimary
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.textColor = model.style.textColorSecondary
        accountCurrentAddressLabel.attributedText = .string(address, with: .callout)
        
        moreButton.tintColor = model.style.textColorPrimary
    }
}

//
// MARK: DashboardStackCardLargeContentView
//

private final class DashboardStackCardLargeContentView: DashboardStackCardContentView {
    
    static let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 9
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    private let accountNameLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let accountCurrentAddressLabel = VerticalLabelContainerView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.label.lineBreakMode = .byTruncatingMiddle
        $0.label.numberOfLines = 1
        $0.label.textAlignment = .center
    })
    
    private let balanceLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.numberOfLines = 2
    })
    
    private let bottomButtonsHStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 16
        $0.clipsToBounds = false
    })
    
    private let sendButton = DashboardStackCardButton.createBottomButton(.hui_send24)
    private let receiveButton = DashboardStackCardButton.createBottomButton(.hui_receive24)
    private let moreButton = DashboardStackCardButton.createBottomButton(.hui_more24)
    
    override init(model: DashboardStackView.Model) {
        super.init(model: model)
        
        addSubview(accountNameLabel)
        addSubview(moreButton)
        addSubview(accountCurrentAddressLabel)

        addSubview(balanceLabel)
        addSubview(bottomButtonsHStackView)
        bottomButtonsHStackView.addArrangedSubview(sendButton)
        bottomButtonsHStackView.addArrangedSubview(receiveButton)
        bottomButtonsHStackView.addArrangedSubview(moreButton)
        
        sendButton.addTarget(self, action: #selector(sendButtonDidClick(_:)), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveButtonDidClick(_:)), for: .touchUpInside)
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = more()
        
        NSLayoutConstraint.activate({
            accountNameLabel.topAnchor.pin(to: topAnchor, constant: 20)
            accountNameLabel.leftAnchor.pin(to: leftAnchor, constant: 22)
            accountCurrentAddressLabel.leftAnchor.pin(to: accountNameLabel.rightAnchor, constant: 12)
            accountNameLabel.heightAnchor.pin(to: 33)
            
            accountCurrentAddressLabel.topAnchor.pin(to: topAnchor, constant: 20)
            accountCurrentAddressLabel.widthAnchor.pin(to: 29)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 20)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 12)
            
            balanceLabel.leftAnchor.pin(to: leftAnchor, constant: 20)
            accountCurrentAddressLabel.leftAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            bottomButtonsHStackView.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 22)
            
            bottomButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 20)
            bottomButtonsHStackView.heightAnchor.pin(to: 52)
            bottomButtonsHStackView.widthAnchor.pin(greaterThan: 128)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: bottomButtonsHStackView.rightAnchor, constant: 12, priority: .required - 1)
            bottomAnchor.pin(to: bottomButtonsHStackView.bottomAnchor, constant: 24)
            
            sendButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            receiveButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            moreButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
        })
        
        _reload()
    }
    
    override func _reload() {
        super._reload()
        
        sendButton.tintColor = model.style.textColorPrimary
        receiveButton.tintColor = model.style.textColorPrimary
        moreButton.tintColor = model.style.textColorPrimary
        
        let name = model.account.name
        let address = Address(rawAddress: model.account.rawAddress)
            .convert(representation: .base64url(flags: [.bounceable]))
        
        accountNameLabel.textColor = model.style.textColorPrimary
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.label.textColor = model.style.textColorSecondary
        accountCurrentAddressLabel.label.attributedText = .string(address, with: .callout)
        
        let balance = model.account.balance
        let balances = (Self.balanceFormatter.string(from: balance) ?? "0.0").components(separatedBy: ".")
        
        balanceLabel.textColor = model.style.textColorPrimary
        balanceLabel.attributedText = NSMutableAttributedString().with({
            $0.append(NSAttributedString(string: balances[0], attributes: [
                .font : UIFont.monospacedSystemFont(ofSize: 57, weight: .bold),
                .paragraphStyle : NSMutableParagraphStyle().with({
                    $0.minimumLineHeight = 57
                    $0.maximumLineHeight = 57
                })
            ]))
            $0.append(.string("\n." + balances[1], with: .body, kern: .four, lineHeight: 17))
        })
    }
}

//
// MARK: DashboardStackCardBackgroundView
//

private final class DashboardStackCardBackgroundView: UIView {
    
    let model: DashboardStackView.Model
    
    let contentView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "CardBackground0")
    })
    
    let visualEffectView = UIVisualEffectView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.effect = UIBlurEffect(style: .light)
    })
    
    let overlayView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    init(model: DashboardStackView.Model) {
        self.model = model
        
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        
        addSubview(contentView)
        addSubview(overlayView)
        
        NSLayoutConstraint.activate({
            contentView.pin(edges: self)
            overlayView.pin(edges: self)
        })
        
        _reload()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    fileprivate func _reload() {
        let style = model.style
        
        backgroundColor = style.backgroundColor
        overlayView.backgroundColor = style.backgroundColor
        
        let hasBackgroundImage = style.backgroundImage != nil
        if hasBackgroundImage {
            imageView.image = style.backgroundImage
            contentView.addSubview(imageView)
            contentView.addSubview(visualEffectView)
            
            imageView.pinned(edges: contentView)
            visualEffectView.pinned(edges: contentView)
        } else {
            imageView.removeFromSuperview()
            visualEffectView.removeFromSuperview()
        }
    }
}

//
// MARK: DashboardStackCardButton
//

private final class DashboardStackCardButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.applyFigmaShadow(
            color: .init(rgb: 0x232020),
            alpha: 0.24,
            x: 0,
            y: 12,
            blur: 12,
            spread: 0,
            cornerRadius: 10
        )
    }
    
    static func createBottomButton(_ image: UIImage) -> UIButton {
        let button = DashboardStackCardButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.insertVisualEffectViewWithEffect(
            UIBlurEffect(style: .systemUltraThinMaterialDark),
            cornerRadius: 26,
            cornerCurve: .circular
        )
        button.insertHighlightingScaleDownAnimation()
        button.insertFeedbackGenerator(style: .medium)
        button.setImage(image, for: .normal)
        return button
    }
}

//
// MARK: DashboardStackCardButton
//

private final class VerticalLabelContainerView: UIView {
    
    let label: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(label)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.bounds = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.width)
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        label.transform = .identity.rotated(by: .pi / 2)
    }
    
    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = label.intrinsicContentSize
        return CGSize(width: intrinsicContentSize.height, height: intrinsicContentSize.width)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let systemLayoutSizeFitting = label.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        return CGSize(width: systemLayoutSizeFitting.height, height: systemLayoutSizeFitting.width)
    }
}
