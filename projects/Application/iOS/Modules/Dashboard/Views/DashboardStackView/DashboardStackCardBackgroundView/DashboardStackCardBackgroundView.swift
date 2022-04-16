//
//  DashboardStackCardBackgroundView.swift
//  iOS
//
//  Created by Anton Spivak on 16.04.2022.
//

import UIKit

final class DashboardStackCardBackgroundView: UIView {
    
    let model: DashboardStackView.Model
    
    private(set) var dimmed: Bool
    private var contentView: DashboardStackCardBackgroundContentView?
    
    private let overlayView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundSecondary
    })
    
    var cornerRadius: CGFloat {
        didSet {
            contentView?.cornerRadius = cornerRadius
            overlayView.layer.cornerRadius = cornerRadius
            overlayView.layer.cornerCurve = .continuous
        }
    }
    
    init(model: DashboardStackView.Model) {
        self.cornerRadius = 0
        self.dimmed = false
        self.model = model
        
        super.init(frame: .zero)
        
        addSubview(overlayView)
        NSLayoutConstraint.activate({
            overlayView.pin(edges: self)
        })
        
        overlayView.layer.borderWidth = 1
        overlayView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        reload()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDimmed(_ dimmed: Bool, animated: Bool, duration: TimeInterval) {
        UIView.performWithoutAnimation({
            contentView?.isHidden = false
            overlayView.isHidden = false
        })
        
        let animations = {
            self.contentView?.alpha = dimmed ? 0 : 1
            self.overlayView.alpha = dimmed ? 1 : 0
        }
        
        let completion = { (_ finished: Bool) in
            self.contentView?.isHidden = (self.contentView?.alpha ?? 0) == 0
            self.overlayView.isHidden = self.overlayView.alpha == 0
        }
        
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut],
                animations: animations,
                completion: completion)
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
    
    // MARK: Private
    
    func reload() {
        contentView?.removeFromSuperview()
        
        let contentView: DashboardStackCardBackgroundContentView
        switch model.account.appearance.kind {
        case let .glass(gradient0Color, gradient1Color):
            contentView = GlassBackgroundView().with({
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.cornerRadius = cornerRadius
                $0.lumineView.gradientView.colors = [
                    UIColor(rgba: gradient0Color),
                    UIColor(rgba: gradient1Color)
                ]
            })
        case let .gradientImage(imageData, shadowColor):
            contentView = GradientImageBackgroundView().with({
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.image = UIImage(data: imageData)
                $0.layer.shadowColor = UIColor(rgba: shadowColor).cgColor
                $0.cornerRadius = cornerRadius
            })
        }
        
        insertSubview(contentView, at: 0)
        NSLayoutConstraint.activate({
            contentView.pin(edges: self)
        })
        
        self.contentView = contentView
    }
}
