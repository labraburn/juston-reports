//
//  CardStackCardLargeContentView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

final class CardStackCardContentLargeView: CardStackCardContentView {
    
    private enum SynchronizationLabelPresentation: Equatable {
        
        case loading(progress: Double)
        case calm
    }
    
    private let accountNameLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let synchronizationLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .footnote)
        $0.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.numberOfLines = 1
    })
    
    private let topButtonsHStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 10
        $0.clipsToBounds = false
    })
    
    private let accountCurrentAddressLabel = VerticalLabelContainerView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        $0.label.lineBreakMode = .byTruncatingMiddle
        $0.label.numberOfLines = 1
        $0.label.textAlignment = .left
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
    
    private let loadingIndicatorView = CardStackCardLoadingView()
    
    private let versionButton = CardStackCardLabel.createTopButton("")
    private let readonlyButton = CardStackCardLabel.createTopButton("AccountCardReadonlyLabel".asLocalizedKey)
    
    private let sendButton = CardStackCardButton.createBottomButton(.hui_send24)
    private let receiveButton = CardStackCardButton.createBottomButton(.hui_receive24)
    private let moreButton = CardStackCardButton.createBottomButton(.hui_more24)
    
    private var synchronizationTimer: Timer? = nil
    private var synchronizationObserver: NSObjectProtocol?
    private var synchronizationPresentation: SynchronizationLabelPresentation = .calm {
        didSet {
            updateSynchronizationLabel()
        }
    }
    
    override init(model: CardStackCard) {
        super.init(model: model)
        
        addSubview(accountNameLabel)
        addSubview(synchronizationLabel)
        addSubview(topButtonsHStackView)
        addSubview(moreButton)
        addSubview(accountCurrentAddressLabel)
        addSubview(balanceLabel)
        addSubview(bottomButtonsHStackView)
        addSubview(loadingIndicatorView)
        
        bottomButtonsHStackView.addArrangedSubview(receiveButton)
        if model.account.isReadonly {
            topButtonsHStackView.addArrangedSubview(readonlyButton)
        } else {
            bottomButtonsHStackView.addArrangedSubview(sendButton)
        }
        bottomButtonsHStackView.addArrangedSubview(moreButton)
        
        accountCurrentAddressLabel.sui_touchAreaInsets = UIEdgeInsets(top: 0, left: -24, right: -24, bottom: 0)
        accountCurrentAddressLabel.insertHighlightingScaleAnimation(0.99)
        accountCurrentAddressLabel.insertFeedbackGenerator(style: .light)
        
        topButtonsHStackView.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, bottom: -24, right: -24)
        versionButton.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -24, bottom: -24, right: -4)
        readonlyButton.sui_touchAreaInsets = UIEdgeInsets(top: -24, left: -4, bottom: -24, right: -24)
        
        versionButton.addTarget(self, action: #selector(versionButtonDidClick(_:)), for: .touchUpInside)
        readonlyButton.addTarget(self, action: #selector(readonlyButtonDidClick(_:)), for: .touchUpInside)
        accountCurrentAddressLabel.addTarget(self, action: #selector(copyAddressButtonDidClick(_:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonDidClick(_:)), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveButtonDidClick(_:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonDidClick(_:)), for: .touchUpInside)
        
        synchronizationObserver = AnnouncementCenter.shared.observe(
            of: AnnouncementSynchronization.self,
            on: .main,
            using: { [weak self] content in
                guard let self = self
                else {
                    return
                }
                
                let progress = content.progress
                if progress > 0 && progress < 1 {
                    self.synchronizationPresentation = .loading(progress: progress)
                } else {
                    self.synchronizationPresentation = .calm
                }
            }
        )
        
        NSLayoutConstraint.activate({
            accountNameLabel.topAnchor.pin(to: topAnchor, constant: 30)
            accountNameLabel.leftAnchor.pin(to: leftAnchor, constant: 26)
            accountCurrentAddressLabel.leftAnchor.pin(to: accountNameLabel.rightAnchor, constant: 12)
            accountNameLabel.heightAnchor.pin(to: 33)
            
            synchronizationLabel.topAnchor.pin(to: accountNameLabel.bottomAnchor, constant: 12)
            synchronizationLabel.leftAnchor.pin(to: leftAnchor, constant: 26)
            accountCurrentAddressLabel.leftAnchor.pin(to: synchronizationLabel.rightAnchor, constant: 12)
            
            topButtonsHStackView.topAnchor.pin(to: synchronizationLabel.bottomAnchor, constant: 14)
            topButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 24)
            topButtonsHStackView.heightAnchor.pin(to: 24)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: topButtonsHStackView.rightAnchor, constant: 12)
            
            accountCurrentAddressLabel.topAnchor.pin(to: topAnchor, constant: 30)
            accountCurrentAddressLabel.widthAnchor.pin(to: 16)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 30)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 20)
            
            balanceLabel.leftAnchor.pin(to: leftAnchor, constant: 26)
            accountCurrentAddressLabel.leftAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            
            bottomButtonsHStackView.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 18)
            bottomButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 26)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: bottomButtonsHStackView.rightAnchor, constant: 12)
            bottomAnchor.pin(to: bottomButtonsHStackView.bottomAnchor, constant: 30)
            
            loadingIndicatorView.centerXAnchor.pin(to: centerXAnchor)
            loadingIndicatorView.topAnchor.pin(to: bottomAnchor, constant: 42)
        })
        
        reload()
        startUpdatesIfNeccessary()
    }
    
    deinit {
        stopUpdates()
    }
    
    override func reload() {
        super.reload()
        
        let tintColor = UIColor(rgba: model.account.appearance.tintColor)
        let controlsForegroundColor = UIColor(rgba: model.account.appearance.controlsForegroundColor)
        let controlsBackgroundColor = UIColor(rgba: model.account.appearance.controlsBackgroundColor)
        
        UIView.performWithoutAnimation({
            if let kind = model.account.contractKind {
                if !topButtonsHStackView.arrangedSubviews.contains(versionButton) {
                    topButtonsHStackView.insertArrangedSubview(versionButton, at: 0)
                }
                
                versionButton.setTitle(kind.name, for: .normal)
                versionButton.layoutIfNeeded()
            } else {
                versionButton.removeFromSuperview()
            }
        })
        
        versionButton.tintColor = controlsForegroundColor.withAlphaComponent(0.8)
        versionButton.backgroundColor = controlsBackgroundColor
        
        readonlyButton.tintColor = controlsForegroundColor.withAlphaComponent(0.8)
        readonlyButton.backgroundColor = controlsBackgroundColor
        
        sendButton.tintColor = controlsForegroundColor
        sendButton.backgroundColor = controlsBackgroundColor
        receiveButton.tintColor = controlsForegroundColor
        receiveButton.backgroundColor = controlsBackgroundColor
        moreButton.tintColor = controlsForegroundColor
        moreButton.backgroundColor = controlsBackgroundColor
        
        let name = model.account.name
        let address = Address(rawValue: model.account.selectedAddress).convert(to: .base64url(flags: []))
        
        accountNameLabel.textColor = tintColor
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.label.textColor = tintColor.withAlphaComponent(0.64)
        accountCurrentAddressLabel.label.attributedText = .string(address, with: .callout)
        
        synchronizationLabel.textColor = tintColor.withAlphaComponent(0.7)
        
        let balance = CurrencyFormatter.string(from: model.account.balance, options: .maximum9minimum9)
        let balances = balance.components(separatedBy: ".")
        
        balanceLabel.textColor = tintColor
        balanceLabel.attributedText = NSMutableAttributedString().with({
            $0.append(NSAttributedString(string: balances[0], attributes: [
                .font : UIFont.monospacedSystemFont(ofSize: 57, weight: .heavy),
                .paragraphStyle : NSMutableParagraphStyle().with({
                    $0.minimumLineHeight = 57
                    $0.maximumLineHeight = 57
                })
            ]))
            $0.append(.string("\n." + balances[1], with: .body, kern: .four, lineHeight: 17))
        })
        
        loadingIndicatorView.setLoading(model.account.isSynchronizing)
        updateSynchronizationLabel()
    }
    
    private func updateSynchronizationLabel() {
        switch synchronizationPresentation {
        case let .loading(progress):
            synchronizationLabel.text = "\("AccountCardSynchronizationInProgress".asLocalizedKey) \(Int(progress * 100))%"
        case .calm:
            if let date = model.account.dateLastSynchronization,
                Date().timeIntervalSince1970 - date.timeIntervalSince1970 > 60
            {
                let formatter = RelativeDateTimeFormatter.shared
                let timeAgo = formatter.localizedString(for: Date(), relativeTo: date)
                synchronizationLabel.text = String(format: "AccountCardSynchronizationDone".asLocalizedKey, timeAgo)
            } else {
                synchronizationLabel.text = "AccountCardSynchronizationNow".asLocalizedKey
            }
        }
    }
    
    private func startUpdatesIfNeccessary() {
        guard synchronizationTimer == nil
        else {
            return
        }
        
        let updates = { [weak self] (_ timer: Timer) in
            guard let self = self, self.synchronizationPresentation == .calm
            else {
                return
            }
            
            self.updateSynchronizationLabel()
        }
        
        let timer = Timer(timeInterval: 60, repeats: true, block: updates)
        RunLoop.main.add(timer, forMode: .common)
        
        self.synchronizationTimer = timer
    }
    
    private func stopUpdates() {
        synchronizationTimer?.invalidate()
        synchronizationTimer = nil
    }
}

extension Contract.Kind {
    
    var name: String {
        switch self {
        case .uninitialized:
            return "AccountContracrtNameUninitialized".asLocalizedKey
        case .walletV1R1:
            return "V1R1"
        case .walletV1R2:
            return "V1R2"
        case .walletV1R3:
            return "V1R3"
        case .walletV2R1:
            return "V2R1"
        case .walletV2R2:
            return "V2R2"
        case .walletV3R1:
            return "V3R1"
        case .walletV3R2:
            return "V3R2"
        case .walletV4R1:
            return "V4R1"
        case .walletV4R2:
            return "V4R2"
        }
    }
}
