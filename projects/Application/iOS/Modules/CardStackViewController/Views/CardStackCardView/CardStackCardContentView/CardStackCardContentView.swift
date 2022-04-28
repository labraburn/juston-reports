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
            attributes: .destructive,
            handler: { [weak self] _ in
                self?.removeButtonDidClick(nil)
            }
        ))
        
        if model.account.subscriptions.contains(.transactions) {
            children.append(UIAction(
                title: "AccountCardUnsubscribeButton".asLocalizedKey,
                handler: { [weak self] _ in
                    self?.unsubscribeButtonDidClick(nil)
                }
            ))
        } else {
            children.append(UIAction(
                title: "AccountCardSubscribeButton".asLocalizedKey,
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
}
