//
//  CardStackCardContentView.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class CardStackCardContentView: UIView {
    
    let model: CardStackCard
    
    weak var delegate: CardStackCardViewDelegate?
    
    init(model: CardStackCard) {
        self.model = model
        super.init(frame: .zero)
        reload()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    func reload() {}
    
    func more() -> UIMenu {
        var children: [UIMenuElement] = []
        
        children.append(UIAction(
            title: "CommonRemove".asLocalizedKey,
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                self?.removeButtonDidClick(nil)
            }
        ))
        
        children.append(UIAction(
            title: "AccountCardResynchronizeButton".asLocalizedKey,
            image: UIImage(systemName: "arrow.clockwise"),
            handler: { [weak self] _ in
                self?.resynchronizeButtonDidClick(nil)
            }
        ))
        
        if model.account.flags.contains(.isNotificationsEnabled) {
            children.append(UIAction(
                title: "AccountCardUnsubscribeButton".asLocalizedKey,
                image: UIImage(systemName: "bell.slash"),
                handler: { [weak self] _ in
                    self?.unsubscribeButtonDidClick(nil)
                }
            ))
        } else {
            children.append(UIAction(
                title: "AccountCardSubscribeButton".asLocalizedKey,
                image: UIImage(systemName: "bell"),
                handler: { [weak self] _ in
                    self?.subscribeButtonDidClick(nil)
                }
            ))
        }
        
        return UIMenu(
            children: children
        )
    }
    
    // MARK: Actions
    
    @objc
    func sendButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(self, didClickSendButtonWithModel: model)
    }
    
    @objc
    func receiveButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(self, didClickReceiveButtonWithModel: model)
    }
    
    @objc
    func removeButtonDidClick(_ sender: UIControl?) {
        delegate?.cardStackCardView(self, didClickRemoveButtonWithModel: model)
    }
    
    @objc
    func subscribeButtonDidClick(_ sender: UIControl?) {
        delegate?.cardStackCardView(self, didClickSubscribeButtonWithModel: model)
    }
    
    @objc
    func unsubscribeButtonDidClick(_ sender: UIControl?) {
        delegate?.cardStackCardView(self, didClickUnsubscrabeButtonWithModel: model)
    }
    
    @objc
    func resynchronizeButtonDidClick(_ sender: UIControl?) {
        delegate?.cardStackCardView(self, didClickResynchronizeButtonWithModel: model)
    }
    
    @objc
    func copyAddressButtonDidClick(_ sender: UIControl?) {
        let address = model.account.selectedAddress
        UIPasteboard.general.string = address.convert(to: .base64url(flags: []))
        
        InAppAnnouncementCenter.shared.post(
            announcement: InAppAnnouncementInfo.self,
            with: .addressCopied
        )
    }
}
