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
        addSubview(moreButton)
        addSubview(accountCurrentAddressLabel)
        addSubview(balanceLabel)
        addSubview(bottomButtonsHStackView)
        
        bottomButtonsHStackView.addArrangedSubview(receiveButton)
        if !model.account.isReadonly {
            bottomButtonsHStackView.addArrangedSubview(sendButton)
        }
        bottomButtonsHStackView.addArrangedSubview(moreButton)
        
        accountCurrentAddressLabel.sui_touchAreaInsets = UIEdgeInsets(top: 0, left: -24, right: -24, bottom: 0)
        accountCurrentAddressLabel.insertHighlightingScaleAnimation(0.99)
        accountCurrentAddressLabel.insertFeedbackGenerator(style: .light)
        
        accountCurrentAddressLabel.addTarget(self, action: #selector(copyAddressButtonDidClick(_:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonDidClick(_:)), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveButtonDidClick(_:)), for: .touchUpInside)
        moreButton.showsMenuAsPrimaryAction = true
        
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
            synchronizationLabel.leftAnchor.pin(to: leftAnchor, constant: 27)
            accountCurrentAddressLabel.leftAnchor.pin(to: synchronizationLabel.rightAnchor, constant: 12)
            
            accountCurrentAddressLabel.topAnchor.pin(to: topAnchor, constant: 30)
            accountCurrentAddressLabel.widthAnchor.pin(to: 16)
            bottomAnchor.pin(to: accountCurrentAddressLabel.bottomAnchor, constant: 30)
            rightAnchor.pin(to: accountCurrentAddressLabel.rightAnchor, constant: 20)
            
            balanceLabel.leftAnchor.pin(to: leftAnchor, constant: 26)
            accountCurrentAddressLabel.leftAnchor.pin(to: balanceLabel.rightAnchor, constant: 12)
            
            bottomButtonsHStackView.topAnchor.pin(to: balanceLabel.bottomAnchor, constant: 18)
            bottomButtonsHStackView.leftAnchor.pin(to: leftAnchor, constant: 26)
            bottomButtonsHStackView.heightAnchor.pin(to: 52)
            bottomButtonsHStackView.widthAnchor.pin(greaterThan: 128)
            accountCurrentAddressLabel.leftAnchor.pin(greaterThan: bottomButtonsHStackView.rightAnchor, constant: 12, priority: .required - 1)
            bottomAnchor.pin(to: bottomButtonsHStackView.bottomAnchor, constant: 30)
            
            if !model.account.isReadonly {
                sendButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            }
            
            receiveButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
            moreButton.widthAnchor.pin(to: bottomButtonsHStackView.heightAnchor)
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
        
        sendButton.tintColor = controlsForegroundColor
        sendButton.backgroundColor = controlsBackgroundColor
        receiveButton.tintColor = controlsForegroundColor
        receiveButton.backgroundColor = controlsBackgroundColor
        moreButton.tintColor = controlsForegroundColor
        moreButton.backgroundColor = controlsBackgroundColor
        
        let name = model.account.name
        let address = model.account.selectedAddress.convert(to: .base64url(flags: []))
        
        accountNameLabel.textColor = tintColor
        accountNameLabel.attributedText = .string(name, with: .title1, kern: .four)
        
        accountCurrentAddressLabel.label.textColor = tintColor.withAlphaComponent(0.64)
        accountCurrentAddressLabel.label.attributedText = .string(address, with: .callout)
        
        synchronizationLabel.textColor = tintColor.withAlphaComponent(0.1)
        
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
        
        moreButton.menu = nil
        moreButton.menu = more()
        
        updateSynchronizationLabel()
    }
    
    private func updateSynchronizationLabel() {
        switch synchronizationPresentation {
        case let .loading(progress):
            synchronizationLabel.text = "Syncing.. \(Int(progress * 100))%"
        case .calm:
            if let date = model.account.dateLastSynchronization,
                Date().timeIntervalSince1970 - date.timeIntervalSince1970 > 60
            {
                let formatter = RelativeDateTimeFormatter.shared
                let timeAgo = formatter.localizedString(for: Date(), relativeTo: date)
                synchronizationLabel.text = "Updated \(timeAgo) ago"
            } else {
                synchronizationLabel.text = "Updated just now"
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
