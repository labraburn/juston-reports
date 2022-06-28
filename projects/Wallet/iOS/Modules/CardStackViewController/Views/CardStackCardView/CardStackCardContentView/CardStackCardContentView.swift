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
    
    // MARK: Actions
    
    @objc
    func sendButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(
            self,
            didClickSendControl: sender,
            model: model
        )
    }
    
    @objc
    func receiveButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(
            self,
            didClickReceiveControl: sender,
            model: model
        )
    }
    
    @objc
    func moreButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(
            self,
            didClickMoreControl: sender,
            model: model
        )
    }
    
    @objc
    func versionButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(
            self,
            didClickVersionControl: sender,
            model: model
        )
    }
    
    @objc
    func readonlyButtonDidClick(_ sender: UIControl) {
        delegate?.cardStackCardView(
            self,
            didClickReadonlyControl: sender,
            model: model
        )
    }
    
    @objc
    func copyAddressButtonDidClick(_ sender: UIControl?) {
        UIPasteboard.general.string = model.account.convienceSelectedAddress
        
        InAppAnnouncementCenter.shared.post(
            announcement: InAppAnnouncementInfo.self,
            with: .addressCopied
        )
    }
}
