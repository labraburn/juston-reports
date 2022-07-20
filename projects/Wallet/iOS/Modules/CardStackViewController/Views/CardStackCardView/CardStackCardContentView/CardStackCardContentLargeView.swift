//
//  CardStackCardLargeContentView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import JustonUI
import JustonCORE

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
    
    private let accountCurrentAddressLabel = VerticalAddressLabelContainerView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        $0.spacing = 14
        $0.clipsToBounds = false
    })
    
    private let loadingIndicatorView = CardStackCardLoadingView()
    
    private let versionButton = CardStackCardLabel.createTopButton("")
    private let readonlyButton = CardStackCardLabel.createTopButton("AccountCardReadonlyLabel".asLocalizedKey)
    
    private let sendButton = CardStackCardButton.createBottomButton(.jus_cardButtonSend55)
    private let receiveButton = CardStackCardButton.createBottomButton(.jus_cardButtonReceive55)
    private let topupButton = CardStackCardButton.createBottomButton(.jus_cardButtonCredit55)
    private let moreButton = CardStackCardButton.createBottomButton(.jus_cardButtonMore55)
    
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
        if !model.account.isReadonly && Country.shared.probably(in: .ru) {
            bottomButtonsHStackView.addArrangedSubview(topupButton)
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
        topupButton.addTarget(self, action: #selector(topupButtonDidClick(_:)), for: .touchUpInside)
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
            
            accountCurrentAddressLabel.topAnchor.pin(to: topAnchor, constant: 28)
            accountCurrentAddressLabel.widthAnchor.pin(to: 16)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 28)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 20)
            
            balanceLabel.leftAnchor.pin(to: leftAnchor, constant: 27)
            accountCurrentAddressLabel.leftAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            
            bottomButtonsHStackView.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 18)
            bottomButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 25)
            bottomButtonsHStackView.heightAnchor.pin(to: 48)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: bottomButtonsHStackView.rightAnchor, constant: 12, priority: .defaultHigh)
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
            if let selectedKind = model.account.selectedContract.kind,
               selectedKind != .uninitialized
            {
                if !topButtonsHStackView.arrangedSubviews.contains(versionButton) {
                    topButtonsHStackView.insertArrangedSubview(versionButton, at: 0)
                }
                
                var name = selectedKind.name
                if let kind = model.account.contractKind, kind == .uninitialized {
                    name = name + " (" + "AccountContracrtNameUninitialized".asLocalizedKey + ")"
                }
                
                versionButton.setTitle(name, for: .normal)
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
        topupButton.tintColor = controlsForegroundColor
        topupButton.backgroundColor = controlsBackgroundColor
        moreButton.tintColor = controlsForegroundColor
        moreButton.backgroundColor = controlsBackgroundColor
        
        let name = model.account.name
        
        accountNameLabel.textColor = tintColor
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.textColor = tintColor.withAlphaComponent(0.64)
        accountCurrentAddressLabel.address = model.account.convienceSelectedAddress.description
        
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
            return "v1R1"
        case .walletV1R2:
            return "v1R2"
        case .walletV1R3:
            return "v1R3"
        case .walletV2R1:
            return "v2R1"
        case .walletV2R2:
            return "v2R2"
        case .walletV3R1:
            return "v3R1"
        case .walletV3R2:
            return "v3R2"
        case .walletV4R1:
            return "v4R1"
        case .walletV4R2:
            return "v4R2"
        }
    }
}
