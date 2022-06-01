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

protocol CardStackCardViewDelegate: AnyObject {
    
    func cardStackCardView(
        _ view: UIView,
        didClickRemoveButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickAppearanceButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickSubscribeButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickUnsubscrabeButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickResynchronizeButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickSendButtonWithModel model: CardStackCard
    )
    
    func cardStackCardView(
        _ view: UIView,
        didClickReceiveButtonWithModel model: CardStackCard
    )
}

final class CardStackCardView: UIView {
    
    enum State: Equatable {
        
        case hidden
        case large
        case compact
    }
    
    let model: CardStackCard
    var observer: PersistenceObjectObserver?
    
    weak var delegate: CardStackCardViewDelegate? {
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
    
    private lazy var compactContentView = CardStackCardContentCompactView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var largeContentView = CardStackCardContentLargeView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var backgroundView = CardStackCardBackgroundView(model: model).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    init(model: CardStackCard) {
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
        observer = model.account.addObjectDidChangeObserver({ [weak self] in
            self?._reload()
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.cornerRadius = cornerRadius
        compactContentView.layer.cornerRadius = cornerRadius
        largeContentView.layer.cornerRadius = cornerRadius
    }
    
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        _update(state: state, animated: true, duration: 0.54)
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
        compactContentView.reload()
        largeContentView.reload()
        backgroundView.reload()
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
            largeContentView.isHidden = false
            compactContentView.isHidden = false
        })
        
        let duration = duration ?? (state != .hidden ? 1.84 : 0.21)
        
        backgroundView.setDimmed(
            state == .hidden || state == .compact || tintAdjustmentMode == .dimmed,
            animated: animated,
            duration: duration
        )
        
        let animations = {
            self.largeContentView.alpha = state == .large ? 1 : 0
            self.compactContentView.alpha = state == .compact ? 1 : 0
        }
        
        let completion = { (_ finished: Bool) in
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
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            if UIView.inheritedAnimationDuration > 0 {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + UIView.inheritedAnimationDuration,
                    execute: {
                        completion(true)
                    }
                )
            } else {
                completion(true)
            }
        }
    }
}
